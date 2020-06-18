BEGIN
    FOR agentie IN (SELECT id_agentie id FROM agentie) LOOP
        DBMS_OUTPUT.PUT_LINE('Agentie id ' || agentie.id);
        FOR turist IN (SELECT distinct a.cod_turist id FROM excursie e JOIN achizitioneaza a ON a.cod_excursie = e.id_excursie WHERE e.cod_agentie = agentie.id) LOOP
            DBMS_OUTPUT.PUT_LINE('  turistul ' || turist.id);
        END LOOP;
    END LOOP;
END;