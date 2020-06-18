/*
4. Definiți un tablou indexat de numere. Introduceți în acest tablou primele 10 de numere naturale.
    a. Afișați numărul de elemente al tabloului şi elementele acestuia.
    b. Setați la valoarea null elementele de pe pozițiile impare. Afișați numărul de elemente al tabloului
    și elementele acestuia.
    c. Ștergeți primul element, elementele de pe pozițiile 5, 6 și 7, respectiv ultimul element. Afișați
    valoarea și indicele primului, respectiv ultimului element. Afișați elementele tabloului și numărul
    acestora.
    d. Ștergeți toate elementele tabloului.
*/

DECLARE
    TYPE tablou_indexat IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    t tablou_indexat;
BEGIN
    -- punctul a
    FOR i IN 1..10 LOOP
        t(i):=i;
    END LOOP;
    
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    
    -- punctul b
    FOR i IN 1..10 LOOP
        IF i mod 2 = 1 THEN t(i):=null;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    
    FOR i IN t.FIRST..t.LAST LOOP
        DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    -- punctul c
    t.DELETE(t.first);
    t.DELETE(5,7);
    t.DELETE(t.last);
    DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first || ' si valoarea ' || nvl(t(t.first),0));
    DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last || ' si valoarea ' || nvl(t(t.last),0));
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        IF t.EXISTS(i) THEN
            DBMS_OUTPUT.PUT(nvl(t(i), 0)|| ' ');
        END IF;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    -- punctul d
    t.delete;
    DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;
/

DECLARE
    TYPE tablou_indexat IS TABLE OF EMP_VA%ROWTYPE INDEX BY BINARY_INTEGER;
    t tablou_indexat;
BEGIN
    -- stergere din tabel si salvare in tablou
    DELETE FROM EMP_VA
    WHERE ROWNUM <= 2
    RETURNING ROWTYPE
    BULK COLLECT INTO t;
    
    --afisare elemente tablou
    DBMS_OUTPUT.PUT_LINE (t(1).employee_id ||' ' || t(1).last_name);
    DBMS_OUTPUT.PUT_LINE (t(2).employee_id ||' ' || t(2).last_name);
    
    --inserare cele 2 linii in tabel
    INSERT INTO emp_va VALUES t(1);
    INSERT INTO emp_va VALUES t(2);
END;
/


DECLARE
    TYPE tablou_imbricat IS TABLE OF NUMBER;
    t tablou_imbricat := tablou_imbricat();
BEGIN
    -- punctul a
    FOR i IN 1..10 LOOP
        t.extend; t(i):=i;
    END LOOP;
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    -- punctul b
    FOR i IN 1..10 LOOP
        IF i mod 2 = 1 THEN t(i):=null;
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        DBMS_OUTPUT.PUT(nvl(t(i), 0) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    
    -- punctul c
    t.DELETE(t.first);
    t.DELETE(5,7);
    t.DELETE(t.last);
    DBMS_OUTPUT.PUT_LINE('Primul element are indicele ' || t.first || ' si valoarea ' || nvl(t(t.first),0));
    DBMS_OUTPUT.PUT_LINE('Ultimul element are indicele ' || t.last || ' si valoarea ' || nvl(t(t.last),0));
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        IF t.EXISTS(i) THEN
            DBMS_OUTPUT.PUT(nvl(t(i), 0)|| ' ');
        END IF;
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
    -- punctul d
    t.delete;
    DBMS_OUTPUT.PUT_LINE('Tabloul are ' || t.COUNT ||' elemente.');
END;


CREATE OR REPLACE TYPE subordonati_va AS VARRAY(10) OF NUMBER(4);
/

CREATE OR REPLACE TYPE subordonati2_va AS TABLE OF NUMBER(4);
/

CREATE TABLE manageri2_va (
    cod_mgr NUMBER(10),
    nume VARCHAR2(20),
    lista subordonati2_va);
    
DECLARE
    v_sub subordonati2_va:= subordonati_va(100,200,300,4,5,6,7,8,9,10);
    v_lista manageri_va.lista%TYPE;
BEGIN
    INSERT INTO manageri2_va
        VALUES (1, 'Mgr 1', v_sub);
    INSERT INTO manageri_va
        VALUES (2, 'Mgr 2', null);
    INSERT INTO manageri_va
        VALUES (3, 'Mgr 3', subordonati2_va(400,500));
    
    SELECT lista 
        INTO v_lista
        FROM manageri_va
        WHERE cod_mgr=1;
    
    FOR j IN v_lista.FIRST..v_lista.LAST loop
        DBMS_OUTPUT.PUT_LINE (v_lista(j));
    END LOOP;
END;
/

DECLARE
    TYPE vector IS VARRAY(2) OF NUMBER;
    t vector:= vector();
BEGIN
    -- punctul a
    FOR i IN 1..10 LOOP
        t.extend; t(i):=i;
    END LOOP;
    DBMS_OUTPUT.PUT('Tabloul are ' || t.COUNT ||' elemente: ');
    FOR i IN t.FIRST..t.LAST LOOP
        DBMS_OUTPUT.PUT(t(i) || ' ');
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
END;