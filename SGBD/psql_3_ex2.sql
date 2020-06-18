/*
Modificaţi exerciţiul anterior astfel încât să obţineţi şi următoarele informaţii:
    - un număr de ordine pentru fiecare angajat care va fi resetat pentru fiecare job
    - pentru fiecare job
        * numărul de angajaţi
        * valoarea lunară a veniturilor angajaţilor
        * valoarea medie a veniturilor angajaţilor
    - indiferent job
        * numărul total de angajaţi
        * valoarea totală lunară a veniturilor angajaţilor
        * valoarea medie a veniturilor angajaţilor
*/

DECLARE
    TYPE refcursor IS REF CURSOR;
    
    CURSOR c_jobs IS
        SELECT 
            job_id, 
            job_title, 
            CURSOR (
                SELECT e.first_name, e.salary
                FROM EMP_VA e
                WHERE e.job_id = j.job_id)
        FROM JOBS j;
        
    c_emp       refcursor;
    
    job_id      JOBS.job_id%TYPE;
    job_name    JOBS.job_title%TYPE;
    
    first_name  EMP_VA.first_name%TYPE;
    salary      EMP_VA.salary%TYPE;
    
    num_emp     NUMBER(5);
    
    job_salary_sum  NUMBER(9, 0);
    job_salary_avg  NUMBER(9, 2);
    
    emp_num_global  NUMBER(9, 0);
    emp_salary_sum  NUMBER(9, 0);
    emp_salary_avg  NUMBER(9, 2);
BEGIN
    emp_num_global := 0;
    emp_salary_sum := 0;
    emp_salary_avg := 0;
    OPEN c_jobs;
    LOOP 
        FETCH c_jobs INTO job_id, job_name, c_emp;
        EXIT WHEN c_jobs%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(job_id || ' ' || job_name);
        num_emp := 0;
        job_salary_sum := 0;
        job_salary_avg := 0;

        -- ref coursours that have been fetched are already opened
        -- consistency!
        LOOP 
            FETCH c_emp INTO first_name, salary;
            EXIT WHEN c_emp%NOTFOUND;
            
            num_emp := num_emp + 1;
            emp_num_global := emp_num_global + 1;
            
            emp_salary_sum := emp_salary_sum + salary;
            job_salary_sum := job_salary_sum + salary;
            
            -- un număr de ordine pentru fiecare angajat care va fi resetat pentru fiecare job
            DBMS_OUTPUT.PUT_LINE('   #' || num_emp || ' ' || first_name || ' ' || salary);
        END LOOP;
        CLOSE c_emp;
        
        IF num_emp = 0 THEN
            DBMS_OUTPUT.PUT_LINE('~~ Nu exista nici un angajat pentru acest job');
        ELSE
/*          - pentru fiecare job
                * numărul de angajaţi
                * valoarea lunară a veniturilor angajaţilor
                * valoarea medie a veniturilor angajaţilor */
            job_salary_avg := job_salary_sum / num_emp;
            DBMS_OUTPUT.PUT_LINE('Statistici pt slujba');
            DBMS_OUTPUT.PUT_LINE('  numar angajati: ' || num_emp);
            DBMS_OUTPUT.PUT_LINE('  suma salariilor:' || job_salary_sum);
            DBMS_OUTPUT.PUT_LINE('  salariul mediu: ' || job_salary_avg);
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    CLOSE c_jobs;
    
    emp_salary_avg := emp_salary_sum / emp_num_global;
/*  - indiferent job
        * numărul total de angajaţi
        * valoarea totală lunară a veniturilor angajaţilor
        * valoarea medie a veniturilor angajaţilor */
    DBMS_OUTPUT.PUT_LINE('Statistici globale');
    DBMS_OUTPUT.PUT_LINE('  numar angajati: ' || emp_num_global);
    DBMS_OUTPUT.PUT_LINE('  suma salariilor:' || emp_salary_sum);
    DBMS_OUTPUT.PUT_LINE('  salariul mediu: ' || emp_salary_avg);
END;