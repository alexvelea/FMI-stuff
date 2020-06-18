<<principal>>
DECLARE
    v_client_id NUMBER(4) := 1600;
    v_client_nume VARCHAR2(50) := 'N1';
    v_nou_client_id NUMBER(3) := 500;
BEGIN
    <<secundar>>
    DECLARE
        v_client_id NUMBER(4) := 0;
        v_client_nume VARCHAR2(50) := 'N2';
        v_nou_client_id NUMBER(3) := 300;
        v_nou_client_nume VARCHAR2(50) := 'N3';
    BEGIN
        v_client_id:= v_nou_client_id;
        principal.v_client_nume := v_client_nume ||' '|| v_nou_client_nume;
        DBMS_OUTPUT.PUT_LINE(v_client_id);
        DBMS_OUTPUT.PUT_LINE(v_client_nume);
        DBMS_OUTPUT.PUT_LINE(v_nou_client_id);
        DBMS_OUTPUT.PUT_LINE(v_nou_client_nume);
        --poziţia 1
    END;
    v_client_id:= (v_client_id *12)/10;
    DBMS_OUTPUT.PUT_LINE(v_client_id);
    DBMS_OUTPUT.PUT_LINE(v_client_nume);
    --poziţia 2
END;

/*
- valoarea variabilei v_client_id la poziţia 1;
- valoarea variabilei v_client_nume la poziţia 1;
- valoarea variabilei v_nou_client_id la poziţia 1;
- valoarea variabilei v_nou_client_nume la poziţia 1;
- valoarea variabilei v_id_client la poziţia 2;
- valoarea variabilei v_client_nume la poziţia 2.
*/