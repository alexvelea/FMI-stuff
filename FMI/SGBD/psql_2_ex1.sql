/*
    Mențineți într-o colecție codurile celor mai prost plătiți 5 angajați care nu câștigă comision. Folosind această
    colecție măriți cu 5% salariul acestor angajați. Afișați valoarea veche a salariului, respectiv valoarea nouă a
    salariului.
*/

DECLARE
    TYPE colectie_angajati IS TABLE OF EMP_VA%ROWTYPE;
    top_angajati colectie_angajati;
BEGIN
    SELECT *
    BULK COLLECT INTO top_angajati
    FROM (SELECT *   
            FROM EMP_VA emp
            WHERE NVL(emp.COMMISSION_PCT, 0) = 0
            ORDER BY emp.SALARY ASC)
    WHERE ROWNUM <= 5;
    
    FOR itr IN top_angajati.first .. top_angajati.last LOOP
        UPDATE EMP_VA e SET e.salary = top_angajati(itr).salary * 1.05 WHERE employee_id = top_angajati(itr).employee_id;
        DBMS_OUTPUT.PUT_LINE('ID:' || top_angajati(itr).EMPLOYEE_ID);
    END LOOP;
END;