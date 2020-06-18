/*
    Modificaţi exerciţiul anterior astfel încât să obţineţi pentru fiecare job primii 5 angajaţi care
    câştigă cel mai mare salariu lunar. Specificaţi dacă pentru un job sunt mai puţin de 5 angajaţi.
*/

DECLARE
    TYPE refcursor IS REF CURSOR;
    
    CURSOR c_jobs IS
        SELECT 
            job_id, 
            job_title, 
            CURSOR (
                SELECT e.first_name, e.salary, e.commission_pct
                FROM EMP_VA e
                WHERE e.job_id = j.job_id
                ORDER BY (e.salary * (1 + NVL(e.commission_pct, 0))) DESC)
        FROM JOBS j;
        
    job_id      JOBS.job_id%TYPE;
    job_name    JOBS.job_title%TYPE;
    c_emp       refcursor;
    
    first_name  EMP_VA.first_name%TYPE;
    salary      EMP_VA.salary%TYPE;
    commission  EMP_VA.commission_pct%TYPE;
    
    num_emp     NUMBER(5);
    emp_salary_total  NUMBER(9, 2);
BEGIN
    OPEN c_jobs;
    LOOP 
        FETCH c_jobs INTO job_id, job_name, c_emp;
        EXIT WHEN c_jobs%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(job_id || ' ' || job_name);
        num_emp := 0;

        LOOP 
            FETCH c_emp INTO first_name, salary, commission;
            EXIT WHEN c_emp%NOTFOUND OR c_emp%ROWCOUNT > 5;
            
            num_emp := num_emp + 1;
            emp_salary_total := salary * (1 + NVL(commission, 0));
            DBMS_OUTPUT.PUT_LINE('    #' || num_emp || ' ' || first_name || ' ' || emp_salary_total);
        END LOOP;
        
        IF c_EMP%ROWCOUNT < 5 THEN
            DBMS_OUTPUT.PUT_LINE('Departamentul nu are 5 angajati');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
        CLOSE c_emp;
    END LOOP;
    CLOSE c_jobs;
END;