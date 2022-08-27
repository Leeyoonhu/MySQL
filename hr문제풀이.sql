use hr;

-- 20220811
select * from employees;
-- 수당을 받는 모든 사원의 이름과 성(Name 별칭), 급여, 업무, 수당 출력
-- 급여 큰 순서 정렬, 같을경우 수당 큰 순서 정렬
SELECT 
    CONCAT(last_name, first_name) 'Name',
    salary,
    job_id,
    commission_pct
FROM
    employees
ORDER BY salary DESC , commission_pct DESC;

-- 모든 사원의 이름과 성(Name 별칭), 급여, 수당여부에 따른 연봉 
-- 수당이 있으면 Salary + Commission , 없으면 Salary Only 
-- 출력 시 연봉이 높은 순

SELECT 
    CONCAT(last_name, first_name) 'Name',
    salary,
    IF(commission_pct IS NOT NULL,
        'Salary + Commission',
        'Salary Only') '수당 여부'
FROM
    employees
ORDER BY salary DESC;

-- 60번 IT부서 사원 급여 12.3% 인상 (반올림) 
-- 성과 이름 (Name 별칭), 급여, 인상된 급여(increase Salary 별칭) 출력
SELECT 
    CONCAT(first_name, last_name) 'Name',
    salary,
    ROUND(salary + salary * 0.123) 'increase Salary'
FROM
    employees;
    
select * from employees;
    
-- 모든 사원의 이름과 성(Name으로 별칭), 입사일, 입사일이 어떤 요일인지 출력
-- 이때 주의 시작인 일요일 부터 출력되도록 정렬
SELECT 
    CONCAT(last_name, first_name) 'Name',
    hire_date,
    DAYNAME(hire_date)
FROM
    employees
ORDER BY DAYOFWEEK(hire_date) ASC;

-- 1996년 5월 20일 부터 1997년 5월 20일 사이에 고용된
-- 사원들의 이름과 성(Name으로 별칭), 업무, 입사일 출력. 입사일 빠른 순 정렬
SELECT 
    CONCAT(last_name, first_name) 'Name', job_id, hire_date
FROM
    employees
WHERE
    hire_date BETWEEN DATE_FORMAT('19960520', '%Y%m%d') AND DATE_FORMAT('19970520', '%Y%m%d')
ORDER BY hire_date ASC
;

-- 각 사원이 소속된 부서별로
-- 급여 합, 급여 평, 급여 최대, 급여 최소 집계
-- 여섯자리와 세자리 구분기호 $와 함께 출력
-- 부서에 소속되지 않은 사원 정보 제외
-- 별칭 순서 DEPARTMENT_ID, SUM_Salary, Avg_Salary, Max_Salary, Min_Salary
SELECT 
    department_id 'DEPARTMENT_ID',
    FORMAT(SUM(salary), 3) 'SUM_Salary',
    FORMAT(ROUND(AVG(salary)), 3) 'Avg_Salary',
    FORMAT(ROUND(MAX(salary)), 3) 'Max_Salary',
    FORMAT(ROUND(MIN(salary)), 3) 'Min_Salary'
FROM
    employees
WHERE
    department_id IS NOT NULL
GROUP BY department_id;

select * from employees;

-- 각 부서별로 최고급여 받는 사원의
-- 사번, 성, 급여 출력. 급여 내림차순 정렬
SELECT 
    employee_id '사번', last_name '성', salary '급여'
FROM
    employees
WHERE
    salary IN (SELECT 
            MAX(salary)
        FROM
            employees
        GROUP BY department_id)
        AND department_id IS NOT NULL
GROUP BY department_id
ORDER BY salary DESC; 

select * from employees;
select * from jobs;
select * from departments;
-- 각 업무별로 급여의 총합
-- 연봉 총합이 높은 업무부터 업무명(job_title)과 연봉총합 출력
SELECT 
  j.job_title, SUM(e.salary)
FROM
    employees e
        INNER JOIN
    jobs j ON e.job_id = j.job_id
GROUP BY e.job_id
ORDER BY SUM(e.salary) DESC;

-- 각 사원에 대해 사번, 이름, 부서명, 매니저이름 출력 
select e.employee_id '사번', e.first_name '이름', d.department_name '부서명', e2.first_name '매니저 이름' 
from employees e 
INNER join departments d inner join employees e2
on e.department_id = d.department_id and e.manager_id = e2.employee_id;

-- 자신의 매니저 보다 채용일이 빠른 사원의
-- 사번, 성, 채용일 출력
select e.employee_id '사번', e.last_name '성', e.hire_date '채용일' 
from employees e  
inner join employees e2 
on e.manager_id = e2.employee_id 
where e.hire_date < e2.hire_date;

-- 자신의 부서 급여 평균보다 
-- 급여가 많은 사원의 사번, 성, 급여 출력
SELECT 
    department_id, employee_id, last_name, salary
FROM
    employees e
WHERE
    salary > ANY (SELECT 
            AVG(salary)
        FROM
            employees e2
        WHERE
            e.department_id = e2.department_id
        GROUP BY department_id)
ORDER BY department_id ASC;
