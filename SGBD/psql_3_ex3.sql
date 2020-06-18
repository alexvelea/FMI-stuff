/*
    Modificaţi exerciţiul anterior astfel încât să obţineţi suma totală alocată lunar pentru plata salariilor şi 
    a comisioanelor tuturor angajaţilor, iar pentru fiecare angajat cât la sută din această sumă câştigă lunar.
*/
DECLARE
    CURSOR c_emp IS
        SELECT e.first_name, e.salary, e.commission_pct
        FROM EMP_VA e;
    
    first_name  EMP_VA.first_name%TYPE;
    salary      EMP_VA.salary%TYPE;
    commission  EMP_VA.commission_pct%TYPE;
    
    emp_salary_sum  NUMBER(9, 0);
    
    emp_salary_avg    NUMBER(9, 5);
    emp_salary_total  NUMBER(9, 2);
BEGIN
    SELECT SUM(salary * (NVL(commission_pct, 0) + 1)) INTO emp_salary_sum FROM EMP_VA;

    OPEN c_emp;
    LOOP
        FETCH c_emp INTO first_name, salary, commission;
        EXIT WHEN c_emp%NOTFOUND;
        
        emp_salary_total := NVL(salary, 0) * (1 + NVL(commission, 0));
        emp_salary_avg := emp_salary_total / emp_salary_sum;
        
        -- un număr de ordine pentru fiecare angajat care va fi resetat pentru fiecare job
        DBMS_OUTPUT.PUT_LINE('    ' || first_name || ' ' || emp_salary_total || ' ' || emp_salary_avg);
    END LOOP;
    CLOSE c_emp;
END;