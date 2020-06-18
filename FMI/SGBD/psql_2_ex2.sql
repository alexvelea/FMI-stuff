/*
    Definiți un tip colecție denumit tip_orase_***. Creați tabelul excursie_*** cu următoarea structură:
    cod_excursie NUMBER(4), denumire VARCHAR2(20), orase tip_orase_*** (lista orașelor care se vizitează),
    status (disponibila sau anulata).
*/

-- Creere tip
-- ??? Nu se poate cu TABLE?
CREATE OR REPLACE TYPE tip_orase_va AS VARRAY(10) of varchar(20);
/

-- Creere tabel
CREATE TABLE excursie_va (
    cod_excursie NUMBER(4) PRIMARY KEY NOT NULL,
    denumire VARCHAR(20),
    orase tip_orase_va
);
/

-- a. Inserați 5 înregistrări în tabel.
INSERT INTO excursie_va (cod_excursie, denumire, orase) 
    VALUES (1, 'Zona buna', tip_orase_va('Sibiu', 'Brasov', 'Sinaia'));
    
INSERT INTO excursie_va (cod_excursie, denumire, orase) 
    VALUES (2, 'La mare la soare', tip_orase_va('Constanta', 'Mamaia', 'Mangalia', 'Neptun', 'Eforie Est'));
    
INSERT INTO excursie_va (cod_excursie, denumire, orase) 
    VALUES (3, 'Safari', tip_orase_va('Bacau', 'Iasi', 'Galati', 'Piatra Neamt', 'Vaslui'));
    
INSERT INTO excursie_va (cod_excursie, denumire, orase) 
    VALUES (4, 'Gratare la munte', tip_orase_va('Busteni', 'Sinaia'));
    
INSERT INTO excursie_va (cod_excursie, denumire, orase) 
    VALUES (5, 'Transilvania pamant', tip_orase_va('Sibiu', 'Brasov', 'Cluj-Napoca', 'Alba', 'Bistrita'));
     
SELECT * FROM EXCURSIE_VA;
     
-- b. Actualizați coloana orase pentru o linie din tabel.
DECLARE
    o excursie_va%rowtype;
BEGIN
    SELECT * INTO o FROM excursie_va WHERE denumire = 'Gratare la munte';
    o.orase.extend();
    o.orase(o.orase.last) := 'Comarnic';
    
    UPDATE excursie_va SET orase = o.orase WHERE cod_excursie = o.cod_excursie;
END;

-- c. Pentru o excursie al cărui cod este dat, afișați numărul de orașe vizitate, respectiv numele orașelor.
DECLARE
    target_cod_excursie excursie_va.cod_excursie%TYPE := &target_cod_excursie;
    e excursie_va%ROWTYPE;
BEGIN
    SELECT * 
        INTO e 
        FROM excursie_va 
        WHERE cod_excursie = target_cod_excursie;
    
    DBMS_OUTPUT.PUT_LINE('Excursie: ' || e.denumire || ' Numar orase: ' || e.orase.count());
    DBMS_OUTPUT.PUT('    ');
    FOR itr in e.orase.first() .. e.orase.last() LOOP
        DBMS_OUTPUT.PUT(e.orase(itr) || ' ');
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
END;

d. Pentru fiecare excursie afișați lista orașelor vizitate.
e. Anulați excursia cu cele mai puține orașe vizitate.