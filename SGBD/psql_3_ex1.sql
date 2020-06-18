/*
    Pentru fiecare job (titlu – care va fi afişat o singură dată) obţineţi lista angajaţilor (nume şi salariu) 
    care lucrează în prezent pe jobul respectiv. Trataţi cazul în care nu există angajaţi care să lucreze în 
    prezent pe un anumit job. Rezolvaţi problema folosind:
*/

-- a. cursoare clasice
DECLARE
    CURSOR c_jobs IS
        SELECT job_id, job_title
        FROM JOBS j;
    
    CURSOR c_emp(p_job_id JOBS.job_id%TYPE) IS
        SELECT e.first_name, e.salary
        FROM EMP_VA e
        WHERE e.job_id = p_job_id;
    
    job_id      JOBS.job_id%TYPE;
    job_name    JOBS.job_title%TYPE;
    
    first_name  EMP_VA.first_name%TYPE;
    salary      EMP_VA.salary%TYPE;
    
BEGIN
    OPEN c_jobs;
    LOOP
        FETCH c_jobs INTO job_id, job_name;
        EXIT WHEN c_jobs%NOTFOUND;
        
        OPEN c_emp(job_id);
        DBMS_OUTPUT.PUT_LINE(job_id || ' ' || job_name);
        
        LOOP
            FETCH c_emp INTO first_name, salary;
            EXIT WHEN c_emp%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE('   ' || first_name || ' ' || salary);
        END LOOP;
        IF c_emp%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('~~ Nu exista nici un angajat pentru acest job');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
        CLOSE c_emp;
        
    END LOOP;
    CLOSE c_jobs;
END;


-- b. ciclu cursoare
DECLARE
    CURSOR c_jobs IS
        SELECT job_id, job_title
        FROM JOBS j;
    
    CURSOR c_emp(p_job_id JOBS.job_id%TYPE) IS
        SELECT e.first_name, e.salary
        FROM EMP_VA e
        WHERE e.job_id = p_job_id;
    
    job_id      JOBS.job_id%TYPE;
    job_name    JOBS.job_title%TYPE;
    
    first_name  EMP_VA.first_name%TYPE;
    salary      EMP_VA.salary%TYPE;
    
    num_emp     NUMBER(5);
BEGIN
    FOR obj_job IN c_jobs LOOP
        EXIT WHEN c_jobs%NOTFOUND;
        job_id :=   obj_job.job_id;
        job_name := obj_job.job_title;
        
        DBMS_OUTPUT.PUT_LINE(job_id || ' ' || job_name);
        num_emp := 0;
        
        FOR obj_emp IN c_emp(job_id) LOOP
            EXIT WHEN c_emp%NOTFOUND;
            first_name :=   obj_emp.first_name;
            salary :=       obj_emp.salary;
            num_emp := num_emp + 1;
            
            DBMS_OUTPUT.PUT_LINE('   ' || first_name || ' ' || salary);
        END LOOP;
        
        IF num_emp = 0 THEN
            DBMS_OUTPUT.PUT_LINE('~~ Nu exista nici un angajat pentru acest job');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;

-- c. ciclu cursoare cu subcereri
DECLARE
    target_job_id      JOBS.job_id%TYPE;
    job_name    JOBS.job_title%TYPE;
    
    first_name  EMP_VA.first_name%TYPE;
    salary      EMP_VA.salary%TYPE;
    
    num_emp     NUMBER(5);
BEGIN
    FOR obj_job IN (
        SELECT job_id, job_title 
        FROM JOBS j) 
    LOOP
        target_job_id :=    obj_job.job_id;
        job_name :=         obj_job.job_title;
        
        DBMS_OUTPUT.PUT_LINE(target_job_id || ' ' || job_name);
        num_emp := 0;
        
        FOR obj_emp IN (
            SELECT e.first_name, e.salary
            FROM EMP_VA e
            WHERE e.job_id = target_job_id)
        LOOP
            first_name :=   obj_emp.first_name;
            salary :=       obj_emp.salary;
            num_emp := num_emp + 1;
            
            DBMS_OUTPUT.PUT_LINE('   ' || first_name || ' ' || salary);
        END LOOP;
        
        IF num_emp = 0 THEN
            DBMS_OUTPUT.PUT_LINE('~~ Nu exista nici un angajat pentru acest job');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
END;

-- d. expresii cursor
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
BEGIN
    OPEN c_jobs;
    LOOP 
        FETCH c_jobs INTO job_id, job_name, c_emp;
        EXIT WHEN c_jobs%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(job_id || ' ' || job_name);
        num_emp := 0;

        -- ref coursours that have been fetched are already opened
        -- consistency!
        LOOP 
            FETCH c_emp INTO first_name, salary;
            EXIT WHEN c_emp%NOTFOUND;
            
            num_emp := num_emp + 1;
            DBMS_OUTPUT.PUT_LINE('   ' || first_name || ' ' || salary);
        END LOOP;
        CLOSE c_emp;
        
        IF num_emp = 0 THEN
            DBMS_OUTPUT.PUT_LINE('~~ Nu exista nici un angajat pentru acest job');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    CLOSE c_jobs;
END;