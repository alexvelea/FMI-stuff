DECLARE 
    d_id    DEPT_VA.DEPARTMENT_ID%TYPE := &v_id;
    exceptie    EXCEPTION;
BEGIN
    
    UPDATE DEPT_VA SET DEPARTMENT_NAME = 'inchis' WHERE DEPARTMENT_ID = d_id;
    IF SQL%NOTFOUND THEN
        RAISE exceptie;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('OK!');
EXCEPTION
    WHEN exceptie THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista departamentul cu id-ul ' || d_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Random error occured: ' || SQLCODE || ' - ' || SQLERRM);
END;
/

SET SERVEROUT ON
DECLARE
 v NUMBER;
 CURSOR c IS
 SELECT employee_id FROM employees;
BEGIN
-- no data found
SELECT employee_id
INTO v
FROM employees
WHERE 1=0;
-- too many rows
SELECT employee_id
INTO v
FROM employees;
 -- when others
v := 's';
 -- cursor already open
 open c;
 open c;
EXCEPTION
WHEN NO_DATA_FOUND THEN
 DBMS_OUTPUT.PUT_LINE (' no data found: ' ||SQLCODE || ' - ' ||
SQLERRM);
WHEN TOO_MANY_ROWS THEN
 DBMS_OUTPUT.PUT_LINE (' too many rows: ' ||SQLCODE || ' - '
|| SQLERRM);
WHEN INVALID_NUMBER THEN
 DBMS_OUTPUT.PUT_LINE (' invalid number: ' ||SQLCODE || ' - '
|| SQLERRM);
WHEN CURSOR_ALREADY_OPEN THEN
 DBMS_OUTPUT.PUT_LINE (' cursor already open: ' ||SQLCODE || '
- ' || SQLERRM);
WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE (' other: ' || SQLCODE || ' - ' || SQLERRM);
END;
/
SET SERVEROUT OFF


CREATE TABLE error_va
(cod NUMBER,
mesaj VARCHAR2(100));
/

DECLARE
    v                   NUMBER := &v;
    x                   NUMBER;
    e_message           VARCHAR2(100) := 'Nu se poate calcula sqrt ';
    exceptie            EXCEPTION;
BEGIN
    IF v < 0 THEN
        RAISE exceptie;
    ELSE
        x := sqrt(v);
        DBMS_OUTPUT.PUT_LINE('-' ||SQRT(v) || '-');
    END IF;
EXCEPTION
    WHEN exceptie THEN
        e_message := e_message || TO_CHAR(v);
        INSERT INTO ERROR_VA VALUES (-20100, e_message);
    WHEN OTHERS THEN
        INSERT INTO ERROR_VA VALUES (SQLCODE, SUBSTR(SQLERRM,1,100));
END;
/