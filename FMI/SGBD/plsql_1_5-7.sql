DECLARE
    v_dep departments.department_name%TYPE;
    max_employees NUMBER(5);
BEGIN
    SELECT MAX(COUNT(*))
    INTO max_employees
    FROM employees e, departments d
    WHERE e.department_id = d.department_id
    GROUP BY d.department_id;
    
    SELECT department_name
    INTO v_dep
    FROM employees e, departments d
    WHERE e.department_id=d.department_id
    GROUP BY department_name
    HAVING COUNT(*) = max_employees;

    DBMS_OUTPUT.PUT_LINE('Departamentul '|| v_dep);
    DBMS_OUTPUT.PUT_LINE(max_employees);
END;