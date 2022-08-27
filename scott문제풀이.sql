-- 예제 되풀이(scottDB.sql 연동)
use scottDB;

-- 20220811

SELECT 
    *
FROM
--  emp하고 , 각 업무별 사원들의 총 급여가 3000이상인 업무에 대해서
-- 업무명과 업무 평균급여 출력, 평균급여 내림차순으로 할것
SELECT 
    job, ROUND(AVG(sal))
FROM
    emp
WHERE
    job NOT LIKE 'SALESMAN'
        AND job IN (SELECT 
            job
        FROM
            emp
        GROUP BY job
        HAVING SUM(sal) >= 3000)
GROUP BY job
ORDER BY AVG(sal) DESC;

-- 전체 사원중에 상관이 있는 사원수 출력
SELECT 
    COUNT(*)
FROM
    emp
WHERE
    MGR IS NOT NULL;

-- emp 테이블에서 이름, 급여, 커미션, 총액(sal+comm)출력
-- 단, comm이 null인애는 제외, 총액많은순 정렬
SELECT 
    ename, sal, comm, sal + comm '총액'
FROM
    emp
WHERE
    comm IS NOT NULL
ORDER BY 총액 DESC;

-- 각 부서별로 같은 업무하는 사람 인원수를 구하여
-- 부서번호, 업무명, 인원수 출력
select deptno '부서번호', job '업무명', count(*) '이름' 
from emp 
where job 
in ( select job from emp group by job) 
group by job;

select * from emp;

-- subquery 이용할 것
-- 전체 사원중 10번 부서에 속한 모든 사원들보다 일찍 입사한 사원 정보 출력
SELECT 
    *
FROM
    emp
WHERE
    hiredate < ALL (SELECT 
            hiredate
        FROM
            emp
        WHERE
            deptno = 10);

-- 10번 부서에 근무하는 사원 중
-- 30번 부서에는 존재하지 않는 직무를 가진 사원 정보, 부서정보 출력
SELECT 
    e.empno, e.ename, e.job, e.deptno, d.dname, d.loc
FROM
    emp e
        INNER JOIN
    dept d ON e.DEPTNO = d.DEPTNO
WHERE
    e.DEPTNO = 10
        AND job NOT IN (SELECT 
            job
        FROM
            emp
        WHERE
            deptno = 30);
            
		
select * from salgrade;
-- 직책이 salesman 인 사람들의 최고 급여
-- 보다 높은 급여를 받는 사원들의
-- 사원 정보, 급여 등급 정보 출력
SELECT 
    e.empno, e.ename, e.sal, s.grade
FROM
    emp e
        INNER JOIN
    salgrade s ON e.sal BETWEEN s.losal AND s.HISAL
WHERE
    e.sal > (SELECT 
            MAX(sal)
        FROM
            emp
        WHERE
            job LIKE 'salesman')
ORDER BY s.grade DESC;

select * from emp;
-- 추가수당을 받는 사원 수와 받지 않는 사원 수 출력
SELECT 
    IF(comm IS NULL, 'X', 'O') 'EXIST_COMM', COUNT(*) 'CNT'
FROM
    emp
GROUP BY EXIST_COMM;

-- 같은 직책에 근무하는 사원이 3명이상
-- 인 직책과 인원수 출력
SELECT 
    job, COUNT(*)
FROM
    emp e
GROUP BY job
HAVING COUNT(*) >= 3;

-- 입사 년도를 기준으로 부서별 입사 인원수 출력
SELECT 
    YEAR(hiredate), deptno, COUNT(*)
FROM
    emp
GROUP BY YEAR(hiredate) , deptno
ORDER BY YEAR(hiredate);

-- 20220812
-- 연습 문제를 위한 table create
create table ex_emp as select * from emp;
create table ex_dept (select * from dept);
create table ex_salgrade AS SELECT * from salgrade;

-- ex_dept 에 50~90번 부서 등록
insert inTO ex_dept valUES (50, 'OPERATIONS', 'LA'), (60, 'ORACLE', 'BUSAN'), (70, 'HTML', 'INCHEON'), (80, 'JAVA', 'ILSAN'), (90, 'SPRING', 'JEJU');
SELECT * FROM EX_DEPT;

-- EX_EMP에 8001~8008 번 데이터 추가
SELECT * FROM EX_EMP;
INSERT INTO EX_EMP 
VALUES 
(8001, 'TEST_USER1', 'MANAGER', 7788, 20210101, 4500, NULL, 60),
(8002, 'TEST_USER2', 'CLERK', 8001, 20210111, 1200, NULL, 60),
(8003, 'TEST_USER3', 'ANALYST', 8001, 20210121, 3300, NULL, 70),
(8004, 'TEST_USER4', 'SALESMAN', 8001, 20210124, 2000, 300, 70),
(8005, 'TEST_USER5', 'CLERK', 8001, 20210215, 3400, 200, 80),
(8006, 'TEST_USER6', 'CLERK', 8001, 20210222, 2800, NULL, 80),
(8007, 'TEST_USER7', 'OPERATOR', 8001, 20210303, 2600, NULL, 90),
(8008, 'TEST_USER8', 'CREATER', 8001, 20210311, 1500, NULL, 90);

-- 60번 부서 사원들의 평균 급여보다 급여가 높은 사원들 70번부서로
UPDATE EX_EMP 
SET 
    DEPTNO = 70
WHERE
    SAL > (SELECT 
            TEMP_SAL
        FROM
            (SELECT 
                AVG(SAL) TEMP_SAL
            FROM
                EX_EMP
            WHERE
                DEPTNO = 60) TEMP);
            
SELECT * FROM EX_EMP ORDER BY DEPTNO DESC;

-- 60번 부서에서 근무하는 사원 중 
-- 입사일이 가장 빠른 사원보다 (2021-01-11)
-- 늦게 입사한 사원의 급여를 10% 인상하고
-- 80번 부서로 옮기기

SELECT HIREDATE FROM EX_EMP WHERE DEPTNO = 60;
UPDATE EX_EMP 
SET 
    DEPTNO = 80,
    SAL = SAL + SAL * 0.1
WHERE
    HIREDATE > (SELECT 
            TEMP_HIREDATE
        FROM
            (SELECT 
                HIREDATE TEMP_HIREDATE
            FROM
                EX_EMP
            WHERE
                DEPTNO = 60) TEMP);
                
SELECT * FROM EX_EMP;
SELECT * FROM EX_SALGRADE;

-- EX_EMP 사원 중, 급여 등급이 5인 사원 삭제(3001~9999)
DELETE FROM EX_EMP 
WHERE EMPNO IN
    (SELECT 
        TEMP_EMPNO
    FROM
        (SELECT 
            e.empno TEMP_EMPNO
        FROM
            EX_EMP e
        INNER JOIN ex_salgrade s ON e.sal BETWEEN losal AND hisal
            AND s.grade = 5) TEMP);

