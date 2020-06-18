/*
    Definiţi un declanşator care să permită lucrul asupra tabelului emp_*** (INSERT, UPDATE, DELETE) 
    decât în intervalul de ore 8:00 - 20:00, de luni până sâmbătă (declanşator la nivel de instrucţiune).
*/
CREATE OR REPLACE TRIGGER ore_de_munca
BEFORE 
    DELETE OR INSERT OR UPDATE
ON EMP_VA
DECLARE
    ora TIMESTAMP;
BEGIN
    IF (EXTRACT(HOUR FROM SYSTIMESTAMP) NOT BETWEEN 8 and 10) THEN
        RAISE_APPLICATION_ERROR(-1, 'Nu astea sunt orele de munca');
    END IF;
END;

/

DELETE FROM EMP_VA WHERE EMPLOYEE_ID = 201;


/* 
    Definiţi un declanşator prin care să nu se permită micşorarea salariilor
    angajaţilor din tabelul emp_*** (declanşator la nivel de linie).
*/
CREATE OR REPLACE TRIGGER majorare_salarii
BEFORE 
    UPDATE
ON EMP_VA
FOR EACH ROW
BEGIN
    IF (:NEW.salary < :OLD.salary) THEN
        RAISE_APPLICATION_ERROR(-2, 'Sindicatul nu permite');
    ELSE
        :NEW.salary := :NEW.salary + 10;
    END IF;
END;

UPDATE EMP_VA
    SET salary = salary + 1
    WHERE employee_id = 201;