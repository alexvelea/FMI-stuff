CREATE TABLE AUDIT_VA(
    utilizator VARCHAR2(30),
    nume_bd VARCHAR2(50),
    eveniment VARCHAR2(20),
    nume_obiect VARCHAR2(30),
    data DATE
);

/

CREATE OR REPLACE TRIGGER audit_trigger_va
AFTER CREATE OR DROP OR ALTER ON SCHEMA
BEGIN
    INSERT INTO AUDIT_VA
    VALUES (SYS.LOGIN_USER, SYS.DATABASE_NAME, SYS.SYSEVENT, SYS.DICTIONARY_OBJ_NAME, SYSDATE);
END;

/

CREATE TABLE VELEA_CREEAZA_TABELE (
    utilizator VARCHAR2(30)
);

DROP TABLE VELEA_CREEAZA_TABELE;

/*
    Exercitiul 1
    Definiţi un declanşator care să permită ştergerea informaţiilor din tabelul dept_*** decât în dacă utilizatorul este SCOTT.
*/

DROP TRIGGER TRIGGER_DEPT_DELETE_VA;
DROP TRIGGER TRIGGER_DEPT_DELETE_VA2;
DROP TRIGGER ex1;

CREATE OR REPLACE TRIGGER TRIGGER_DEPT_DELETE_VA
BEFORE DELETE OR INSERT ON DEPT_VA
BEGIN
    IF USER = UPPER('grupa33') THEN
        RAISE_APPLICATION_ERROR(-20900, 'Grupa 33 nu poate sa stearga nioc nioc');
    END IF;
END;
/

DELETE FROM DEPT_VA WHERE manager_id = NULL;

INSERT INTO DEPT_VA VALUES(10,	'AdministrationVELEA2',	200,	1700);


CREATE OR REPLACE TRIGGER TRIGGER_EMP_VA
BEFORE UPDATE ON EMP_VA
FOR EACH ROW
BEGIN
    IF :NEW.COMMISSION_PCT > 0.5 THEN
        RAISE_APPLICATION_ERROR(-20900, 'Comision prea mare nioc nioc');
    END IF;
END;

UPDATE EMP_VA SET COMMISSION_PCT = 0.8 WHERE EMPLOYEE_ID = 100;

/*
    a. Introduceţi în tabelul info_dept_*** coloana numar care va reprezenta pentru fiecare
    departament numărul de angajaţi care lucrează în departamentul respectiv. Populaţi cu date
    această coloană pe baza informaţiilor din schemă.
*/
-- creem tabelul
ALTER TABLE INFO_DEPT_VA 
    ADD numar NUMBER(5, 0) DEFAULT 0 NOT NULL; 
    
-- poponam tabelul cu numarul de angajati cu for
BEGIN
    -- dam cu for fiecare departament
    FOR dept_obj IN (SELECT id FROM INFO_DEPT_VA) LOOP
        -- obtinem id-ul departamentului curent din dept_obj.id
        -- setam 'numar' ca fiind egal cu count(*)
        UPDATE INFO_DEPT_VA 
            SET numar = (SELECT count(*) FROM EMP_VA WHERE department_id = dept_obj.id)
            WHERE id = dept_obj.id;
    END LOOP;
END;

-- poponam tabelul cu numarul de angajati fara for
UPDATE INFO_DEPT_VA d
    SET d.numar = (SELECT count(*) FROM EMP_VA WHERE department_id = d.id);

-- putem tot 0 ca sa mai retestam 
UPDATE INFO_DEPT_VA SET numar = 0;

/*
    b. Definiţi un declanşator care va actualiza automat această coloană în funcţie de actualizările
    realizate asupra tabelului info_emp_***.
*/

CREATE OR REPLACE TRIGGER INFO_DEPT_UP_TO_DATE
BEFORE UPDATE OR INSERT OR DELETE ON INFO_EMP_VA
FOR EACH ROW
BEGIN
    IF DELETING THEN 
        UPDATE INFO_DEPT_VA idept
            SET idept.numar = idept.numar - 1
            WHERE idept.nume = (SELECT d.DEPARTMENT_NAME FROM departments d WHERE d.department_id = :OLD.id_dept);
    ELSIF UPDATING('id_dept') THEN
        UPDATE INFO_DEPT_VA idept
                SET idept.numar = idept.numar - 1
                WHERE idept.nume = (SELECT d.DEPARTMENT_NAME FROM departments d WHERE d.department_id = :OLD.id_dept);
        UPDATE INFO_DEPT_VA idept
            SET idept.numar = idept.numar + 1
            WHERE idept.nume = (SELECT d.DEPARTMENT_NAME FROM departments d WHERE d.department_id = :NEW.id_dept);
    ELSIF INSERTING THEN
        UPDATE INFO_DEPT_VA idept
            SET idept.numar = idept.numar + 1
            WHERE idept.nume = (SELECT d.DEPARTMENT_NAME FROM departments d WHERE d.department_id = :NEW.id_dept);
    END IF;
END;