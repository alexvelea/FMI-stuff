SELECT sysdate FROM dual;

FOR statie IN (SELECT * FROM statie s WHERE s.cod_companie = v_cod_companie) LOOP
    SELECT MAX(a.data_achizitie) INTO achizitie_recenta
        FROM ACHIZITIE a WHERE a.cod_st = cod_statie;
        
    IF achizitie_recenta < sysdata - 10 THEN
        OK
    ELSE
        NO
    END IF;
END LOOP;

DECLARE
    PROCEDURE ex1(v_cod_companie A_B_COMPANIE.COD%TYPE)
    IS
        achizitie_recenta A_B_ACHIZITIE.DATA_ACHIZITIE%TYPE;
    BEGIN
        FOR statie IN (SELECT * FROM A_B_STATIE s WHERE s.cod_companie = v_cod_companie) LOOP
            SELECT MAX(a.data_achizitie) INTO achizitie_recenta
                FROM A_B_ACHIZITIE a WHERE a.cod_st = statie.cod_statie;
                
            IF achizitie_recenta < sysdate - 20 THEN
                DBMS_OUTPUT.PUT_LINE('Statia ' || statie.denumire || ' e ok');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Statia ' || statie.denumire || ' nu e ok');
            END IF;
        END LOOP;
    END;
BEGIN
    ex1(1);
END;

/
/*
    Link la fisier: http://193.226.51.37/down/SGBD/test_plsql_1.pdf
    Am creeat tabele
    A_B_{STATIE,ACHIZITIE,PRODUS,COMPANIE}
    A - ca sa fie primele
    B - e testul 1 aparent bag pula
    
    Ex 1: incepe la linia 24
    Ex 2: incepe la linia 82
    Ex 3: incepe la linia 162
    Ex 4: incepe la linia 249
    Ex 5: incepe la linia 338
    
    Va rog sa nu distrugeti datele.
    PLS
*/

/* Schemele relaţionale ale modelului folosit sunt:
 STATIE(cod_statie, denumire,nr_angajati, cod_companie, capacitate, oras)
 ACHIZITIE (cod_st, cod_prod, data_achizitie, cantitate, pret_achizitie)
 PRODUS (cod_produs, denumire, pret_vanzare)
 COMPANIE (cod, denumire, capital, presedinte)  */

/* 1. Subprogram care primeşte ca parametru un cod de companie şi întoarce lista staţiilor
companiei care nu au mai achiziţionat produse în ultimele 10 zile. Apelaţi. (3p) */

/*
Modificati in '1 zi ' nu 10, sa fie queriul mai usor
aici aveti pt statii cand s-a facut cea mai mare achizitie
cod_statie data cod_companie
102	05-01-2019	1
101	05-01-2019	1
103	09-01-2019	4
4	09-01-2019	2
6	09-01-2019	2
5	09-01-2019	4
3	17-01-2019	2
2	17-01-2019	1
1	17-01-2019	1
*/

DECLARE
    -- stocam linii -pentru ca nu e precizat, intr-un tabel
    TYPE ANS IS TABLE OF A_B_STATIE%ROWTYPE;
    
    v_cod_companie  A_B_COMPANIE.COD%TYPE := &v_cod_companie;
    v_raspuns       ANS := ANS();
    
    FUNCTION solve(v_cod_companie IN A_B_COMPANIE.COD%TYPE) 
    RETURN ANS 
    IS
        v_raspuns ANS := ANS();
    BEGIN
        SELECT s.* -- stocam toate coloanele statiei
        BULK COLLECT INTO v_raspuns -- stocam in tabel selectul
        FROM A_B_COMPANIE c
        JOIN A_B_STATIE s
            ON s.cod_companie = c.cod -- facem join pe codul companiei
        JOIN ( -- selectam pentru fieare statie care e data maxima de achizitie si codul - ca sa putem sa facem join
            SELECT MAX(data_achizitie) data_achizitie, cod_st
            FROM A_B_ACHIZITIE
            GROUP BY cod_st
        ) a
            ON s.cod_statie = a.cod_st  -- facem joinul. Acum avem rows care contin statii care au asociata compania si data ultimei achizitii
        WHERE
            c.cod = v_cod_companie AND -- selectam doar statiile din compania curenta
            a.data_achizitie < (SELECT sysdate - 1 FROM DUAL); -- asa se selecteaza data curenta
            -- daca aveti nevoie de data curenta - 1 ora, o sa faceti sysdate - 1/24 
            -- pentur minute 1/24/60
        
        return v_raspuns;
    END solve;
BEGIN
    v_raspuns := solve(v_cod_companie);
    FOR i IN 1..v_raspuns.count LOOP
        DBMS_OUTPUT.PUT_LINE('Statie ' || v_raspuns(i).cod_statie);
    END LOOP;
END;

/*
 2. Subprogram care primeşte ca parametru un cod de produs, afişează denumirea şi oraşul
staţiilor în care a fost distribuit la un preţ de achiziţie mai mic decât preţul de vânzare.
Subprogramul va returna cantitatea totală vandută din produsul dat ca parametru. Trataţi
erorile care pot sa apară. Apelaţi. (3p) 
*/

/*
!@#$% suntem interesati de valorile negative
denumire_statie cod_produs pret_achizitie - pret_vanzare
manastur	    1	0
victoriei	    1	-1
universitate	1	-1
zorilor	        2	1
unirii	        2	0
grozavesti	    2	0
gara de nord	3	1
basarab	        4	-1
unirii	        4	1
zorilor	        5	1
iulius	        5	-1
victoriei	    101	5
universitate	101	-20
grozavesti	    102	0
universitate	102	-500
gara de nord	103	-899
basarab	        103	-100
*/
DECLARE
    in_cod_produs   A_B_PRODUS.COD_PRODUS%TYPE;
    p_sum_cantitate NUMBER;

    FUNCTION solve2(p_cod_produs A_B_PRODUS.COD_PRODUS%TYPE) 
    RETURN NUMBER 
    IS    
        ans NUMBER(10);
    BEGIN
        FOR itr IN (
            -- fun fact: daca dai cu for printr-un select nu arunca exceptie cu 'no data found sau ceva'
            -- cum face atunci cand faci select id into ceva from statie where id = 0
            SELECT s.denumire denumire, s.oras oras -- selectam denumirea si orasul. mie imi place sa le si dau nume ca sa stiu ca merge
                -- plecand de la produs, linkam la el achizitiile, apoi statiile
                FROM a_b_produs p
                JOIN a_b_achizitie a
                    ON a.cod_prod = p.cod_produs
                JOIN a_b_statie s
                    ON s.cod_statie = a.cod_st
                -- punem chestia care ne cere sa o facem
                WHERE a.pret_achizitie < p.pret_vanzare AND p.cod_produs = p_cod_produs) 
        LOOP
            -- afisam la misto chestii
            DBMS_OUTPUT.PUT_LINE('denumire statie: ' || itr.denumire || ' oras: ' || itr.oras);
        END LOOP;
        
        -- facem suma la misto
        SELECT SUM(a.cantitate) INTO ans
            FROM a_b_produs p
            JOIN a_b_achizitie a
            ON a.cod_prod = p.cod_produs
            WHERE p.cod_produs = p_cod_produs;
        
        -- daca suma e null inseamna ca nu exista element cu idul ala si o sa returnam no data found pt ca de ce nu?
        IF ans IS NULL THEN
            RAISE NO_DATA_FOUND;
            RETURN 0;
        END IF;
        
        RETURN ans;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE (' no data found: ' ||SQLCODE || ' - ' || SQLERRM);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE (SQLCODE || ' - ' || SQLERRM);
    END;
BEGIN
    in_cod_produs := &introduceti_cod_produs;
    p_sum_cantitate := solve2(in_cod_produs);
    DBMS_OUTPUT.PUT_LINE('Cantitate: ' || p_sum_cantitate);
END;


/*
    3. Să se adauge tabelului statie o coloană stoc care să reprezinte cantitatea totală de
    produse achiziţionate de fiecare staţie. Actualizaţi această coloană. Să se scrie un trigger
    care asigură consistenţa acestei coloane. (3p)
*/

/*
    IMI BAG PICIOARELE DACA FUTETI DATELE
    SA MOR EU
    FACETI TABELE A_B_STATIE_NUME si A_D_ACHIZITIE_NUME
    click dreapta pe tabel / copy - selectati include data
    sa puneti A_D sa ramana primele 4 sortate pwp ms mult dau funda
*/

-- adaugam coloana
ALTER TABLE A_D_STATIE_VA
ADD STOC NUMBER;
/

-- inseram date in coloana aia
-- chestia asta se poate face in mai multe feluri, inclusiv cu un singur query.
-- dar e mai bine sa faci chestii simple decat sa te complici, desii poate dureaza 2 min in plus sau ceva
DECLARE
    p_sum_cantitate NUMBER;
BEGIN
    -- iteram cu for id-ul statiei - ca baietii
    FOR i IN (SELECT s.COD_STATIE cod_statie FROM A_D_STATIE_VA s)
    LOOP
        -- selectam cantitatea de produse pentru id-ul selectat, el fiind egal cu i.cod_statie
        SELECT SUM(a.cantitate) INTO p_sum_cantitate
            FROM A_D_STATIE_VA s
            JOIN A_B_ACHIZITIE a
            ON a.cod_st = s.cod_statie
            WHERE a.cod_st = s.cod_statie and a.cod_st = i.cod_statie;
            
        -- updatam stocul pentru i.cod_statie cu noua valoare!
        UPDATE A_D_STATIE_VA s
            SET s.stoc = p_sum_cantitate
            WHERE s.cod_statie = i.cod_statie;
    END LOOP;
END;

/

CREATE OR REPLACE TYPE NUMERE_TELEFON IS varray(20) OF varchar2(20);
ALTER TABLE A_B_PRODUS
    ADD COLUMN 
        nr_telefon NUMERE_TELEFON;
        
INSERT INTO A_B_PRODUS
    (cod_produs, nr_telefon)
VALUES
    (10, NUMERE_TELEFON('0740424743', 'ewqewq', 'ewqewqewq'));

CREATE OR REPLACE PROCEDURE p1 IS
BEGIN
    
END;

CREATE OR REPLACE FUNCTION p1(p_cod_achizitie ACHIZITIE.COD%TYPE) RETURN PRODUS.COD%TYPE
IS
    ans PRODUS.COD%TYPE;
BEGIN
    
    return ans;
END;


-- adaugam triggerul
CREATE OR REPLACE TRIGGER A_D_STATIE_WATCHER 
-- after sau before, nu prea conteaza sincer in cazul asta. In general vrei before dar aici e ok ambele
AFTER 
-- ALL THE OPERATIONS
    UPDATE OR INSERT OR DELETE 
-- ne intereseaza doar 2 coloane
    OF COD_ST, CANTITATE
-- tabelul e achizitie - sa il puneti pe tabelul vostru ca altfel va tai
    ON A_D_ACHIZITIE_VA
-- pt fiecare linie meow meow 
    FOR EACH ROW
BEGIN
-- daca se sterge o achizitie o sa scadem doar cantitatea
    IF DELETING THEN
        UPDATE A_D_STATIE_VA SET STOC = STOC - :OLD.CANTITATE WHERE COD_STATIE = :OLD.COD_ST;
        
-- daca se adauga o achizitie doar o sa crestem cantitatea
    ELSIF INSERTING THEN
        UPDATE A_D_STATIE_VA SET STOC = STOC + :NEW.CANTITATE WHERE COD_STATIE = :NEW.COD_ST;
        
-- daca se modifica  e complicat, ca se poate modifica si codul statie, ceea ce inseamna ca se transfera de la o statie la alta
-- probabil profa e prea proasta sa isi dea seama de asta sincer, dar totusi aici e
    ELSE
        -- daca s-a modificat stocul, scadel cantitatea veche de la statia veche
        -- si adaugam cantitatea noua la cea noua - se poate modifica si cantitatea nu doar statia!
        IF (:NEW.COD_ST != :OLD.COD_ST) THEN
            UPDATE A_D_STATIE_VA SET STOC = STOC - :OLD.CANTITATE WHERE COD_STATIE = :OLD.COD_ST;
            UPDATE A_D_STATIE_VA SET STOC = STOC + :NEW.CANTITATE WHERE COD_STATIE = :NEW.COD_ST;
        ELSE
            -- altfel adaugam diferenta new - old
            UPDATE A_D_STATIE_VA SET STOC = STOC + (:NEW.CANTITATE - :OLD.CANTITATE) WHERE COD_STATIE = :OLD.COD_ST;
        END IF;
        
        -- fun fact: e corect sa scriem doar
        -- UPDATE A_D_STATIE_VA SET STOC = STOC - :OLD.CANTITATE WHERE COD_STATIE = :OLD.COD_ST;
        -- UPDATE A_D_STATIE_VA SET STOC = STOC + :NEW.CANTITATE WHERE COD_STATIE = :NEW.COD_ST;
        -- fara nici un if. sa va ganditi de ce
    END IF;
END;
/

/*
    Sa se adauge trigger* care nu permite ca pentru o statie stocul sa devina mai mare ca capacitatea.

    Am sa pun mai jos un cod de SQP care sa faca capacitatea >= stocul ca sa nu fie inconsistente :)
    Lucrati pe tabelele voastre ploxi
    Nu stiu daca se poate adauga un trigger pe mai multe tabele ...
    
    Cred ca exercitiul asta e prea greu pt test sincer :(
    Nu o sa apara asa ceva
    Dar e ok sa va uitati/ganditi peste el
    
    !!! Foarte imporatant
    Trebuie sa aveti triggerul de la ex 3 care tine up-to-date valorile
    Daca ati rezolvat ex 3 intainte sa pun eu asta, sa puneti neaparat AFTER la triggerul de la ex 3
        - am testat si nu inteleg absolut nimic din ce se intampla
    Logica e urmatoarea:
        - sincer, asta e prea complicat de asta o sa zic pt ca sigur nu intra in test, dar e periculos sa lucrati cu mai
        - multe triggere. Eu personal NU STIU IN CE ORDINE SE EXECUTA.
        - asa ca il punem pe cel care face up to date chestiile AFTER
        - si pe astea BEFORE :)
        - si presupunem ca 'stoc' nu e up to date
        - stiu
*/

-- facem capacitatea sa fie >= stoc
-- AI DE PULA MEA SQL NU ARE MAXIMUL A 2 FUCKING NUMERE
-- UPDATE A_D_STATIE_VA s
-- SET CAPACITATE = MAX(s.CAPACITATE, s.STOC);

BEGIN
    FOR i IN (SELECT s.* FROM A_D_STATIE_VA s) LOOP
        IF (i.stoc > i.capacitate) THEN
            UPDATE A_D_STATIE_VA
                SET CAPACITATE = i.stoc 
                WHERE COD_STATIE = i.cod_statie;
        END IF;
    END LOOP;
END;

-- adaugam triggerul
-- nu vi se pare dubios cum cantitate poate sa aiba atatia T? pe bune acum .. canTiTaTe
CREATE OR REPLACE TRIGGER STATIE_CAPACITY_WATCHER_VA_1
BEFORE
    UPDATE OR INSERT
    OF CANTITATE, COD_ST
    ON A_D_ACHIZITIE_VA
    FOR EACH ROW
DECLARE
    p_capacitate_a  NUMBER;
    p_stoc_a        NUMBER;
BEGIN
-- e mai logic in capul meu

    -- inseram stocul si capacitatea la elementul cu cod_statie :NEW (care apre si la update si la insert)
    -- sa fiu sincer nu stiu ce plm e :OLD pt insert
    -- cred ca are doar null, dar sincer chiar nu stiu si nu imi pasa
    -- sper sa fie null
    SELECT s.stoc, s.capacitate INTO p_stoc_a, p_capacitate_a
    FROM A_D_STATIE_VA s
    WHERE s.cod_statie = :NEW.cod_st;
    
    IF p_capacitate_a < p_stoc_a + :NEW.cantitate - NVL(:OLD.cantitate, 0) THEN
        RAISE_APPLICATION_ERROR(-1, 'Nu ai voie sa faci asta hihi');
    END IF;
    
    -- nu poti sa ai achizitii cu cantitate negativa cine pula mea stie
    -- daca cantitatea din achizitii e strict pozitiva, valoarea old.stoc ar trebui doar sa scada 
    -- pentru ca doar se ia din ea
    -- dar cumva daca schimbi ID-ul trebuie doar sa aduni cantitatea noua FUCK MY LIFE
    IF UPDATING AND :OLD.cod_st != :NEW.cod_st AND p_capacitate_a < p_stoc_a + :NEW.cantitate THEN 
        RAISE_APPLICATION_ERROR(-1, 'Nu ai voie sa faci asta hihi');
    END IF;
END;
    
    
-- mai punem un trigger ca sa nu putem seta capacitatea prost la magazin hahahah
-- exercitiu care se rezolva cu 2 triggere hahaha malefic
CREATE OR REPLACE TRIGGER STATIE_CAPACITY_WATCHER_VA_2
BEFORE
    UPDATE OR INSERT
    OF CAPACITATE
    ON A_D_STATIE_VA
    FOR EACH ROW
BEGIN
    IF :NEW.stoc > :NEW.capacitate THEN
        RAISE_APPLICATION_ERROR(-1, 'Nu ai voie sa faci asta hihi2');
    END IF;
END;

/*
    ex 5. Pentru fiecare companie sa se afiseze orasul si denumirea statiei care a consumat cei mai multi bani.
    De asemenea, afisati si cati bani a consumat! 
    Daca vreti si denumirea companiei. pt cei smecheri.
    
    Problema bonus: cum obtinem tabelul de mai jos?
    - solutia e dupa partea de cod pl/sql
*/
/*
Ca sa va ajute
COD_COMPANIE NUME COMPANIE COD_STATIE ORAS DENUMIRE SUMA
1	sony	102	cluj	manastur	40
1	sony	2	bucuresti	grozavesti	8000
1	sony	1	bucuresit	universitate	90560
1	sony	101	cluj	iulius	49
2	apple	3	bucuresti	gara de nord	7422
2	apple	4	bucuresti	victoriei	9257
2	apple	6	bucuresti	basarab	948
4	samsung	103	cluj	zorilor	195
4	samsung	5	bucuresti	unirii	725
*/

-- pentru mai multe explicatii uitativa jos de tot - dupa exercitiu
DECLARE
    v_oras          A_B_STATIE.DENUMIRE%TYPE;
    v_nume_statie   A_B_STATIE.DENUMIRE%TYPE;
    v_bani          NUMBER;
    
BEGIN
    -- dam cu for id-ul, e mai usor asa parca
    FOR i IN (SELECT COD, DENUMIRE FROM A_B_COMPANIE) LOOP
        SELECT oras, denumire, suma INTO v_oras, v_nume_statie, v_bani
        FROM (
            SELECT * -- luam tot, numele se pastreaza
                FROM (
                    SELECT 
                        s.ORAS oras, 
                        s.DENUMIRE denumire,
                        (SELECT SUM(a.pret_achizitie * a.cantitate) suma -- ii dam nume! 
                            FROM A_B_ACHIZITIE a 
                            WHERE a.cod_st = s.cod_statie) suma -- ii dam nume din nou
                    FROM A_B_STATIE s
                    WHERE s.cod_companie = i.cod
                    ORDER BY suma desc
                )
                WHERE ROWNUM = 1
        );
        DBMS_OUTPUT.PUT_LINE('Compania ~' || i.denumire || '~ nume statie ~' || v_nume_statie || '~ oras ~' || v_oras || '~ bani sparti ' || v_bani);
    END LOOP;
END;

/*
    Hai sa rezolvam problema
    Sa incepem cu inceputul
    
    Nu stim nimic
    Nu ni se dau date
    Nimic
    
    Hai sa incepem de undeva
    dam cu for compania
    acum avem ceva! - idul companiei
    
    DISCLAIMER - prin INFORMATIE ma refer la denumire statie, oras statie si bani consumati
    
    In mod surprinzator, la problemele astea unde e super super complicat ce trebuie sa faci, trebuie sa o iei incet
    SI MAI ALES INVERS
    #0
    - gasim o cale de a ajunge de la ce avem la informatia de care avem nevoie
    aici calea e
    - companie - statie - achizitie
    toate astea o sa se faca cu joinuri
    #1 stiind id-ul statiei, cum aflam banii consumati
    - presupunem ca statia e 1
*/

-- luam toate achizitiile si le selectam pe cele care apartin companiei cu id-ul 1.
-- returnam suma
SELECT SUM(a.pret_achizitie * a.cantitate) suma -- ii dam nume! 
    FROM A_B_ACHIZITIE a 
    WHERE a.cod_st = 1;
    
/*
    cum luam INFORMATIE pentru toate companiile?
    sa presupunem ca nu ne intereseaza suma de bani
*/

SELECT s.ORAS oras, s.DENUMIRE denumire
FROM A_B_STATIE s;

/*
    acum, daca noi stim sa obtinem o informatie avand setat id-ul statiei, aceasta informatie
    'devine' un fel de membru.
    In sensul de poate fi folosit asa
    in felul urmator:
*/

SELECT 
    s.ORAS oras, 
    s.DENUMIRE denumire,
    (SELECT SUM(a.pret_achizitie * a.cantitate) suma -- ii dam nume! 
        FROM A_B_ACHIZITIE a 
        WHERE a.cod_st = s.cod_statie) suma -- ii dam nume din nou
FROM A_B_STATIE s;

/*
    tot ce am facut e ca am pus acolo 'membrul' si in loc de 1 am pus s.cod_statie
    astfel am 'hardcodat' codul statiei cand el nu e hardcodat!
    
    pasul 2: 
    hai sa luam in considerare doar statiile care apartin companiei c(momentan scriem 1) - pentru ca deja avem informatia necesare
*/

SELECT 
    s.ORAS oras, 
    s.DENUMIRE denumire,
    (SELECT SUM(a.pret_achizitie * a.cantitate) suma -- ii dam nume! 
        FROM A_B_ACHIZITIE a 
        WHERE a.cod_st = s.cod_statie) suma -- ii dam nume din nou
FROM A_B_STATIE s
WHERE s.cod_companie = 1;

/*
    SUPER 
    acum stim pentru compania 1 care sunt statiile si avem toata informatia
    
    #3
    hai sa le sortam
*/

SELECT 
    s.ORAS oras, 
    s.DENUMIRE denumire,
    (SELECT SUM(a.pret_achizitie * a.cantitate) suma -- ii dam nume! 
        FROM A_B_ACHIZITIE a 
        WHERE a.cod_st = s.cod_statie) suma -- ii dam nume din nou
FROM A_B_STATIE s
WHERE s.cod_companie = 1
ORDER BY suma desc; -- adaugam asta. nu punem s.suma pt ca suma nu e un membru a lui s

/*
    Pas 4
    de fiecare daca cand ni se cere ceva care are o chestie maximma/minim orice
    le punem in ordinea aia
    si o luam pe prima
*/

SELECT * -- luam tot, numele se pastreaza
FROM (
    SELECT 
        s.ORAS oras, 
        s.DENUMIRE denumire,
        (SELECT SUM(a.pret_achizitie * a.cantitate) suma -- ii dam nume! 
            FROM A_B_ACHIZITIE a 
            WHERE a.cod_st = s.cod_statie) suma -- ii dam nume din nou
    FROM A_B_STATIE s
    WHERE s.cod_companie = 1
    ORDER BY suma desc
)
WHERE ROWNUM = 1;

/*
    Acum avem toata informatia selectata avand hardcodat codul companiei (1)
    
    pe care il putem da cu for
    e mai complicat sa nu il dam cu for pentru ca chestia noastra contine mai multa informatie
    dar se poate da cu for!
*/


-- ca sa obtinem tabelasul cu chestii de mai sus
SELECT c.cod, c.denumire, s.cod_statie, s.oras, s.denumire, 
    (SELECT SUM(a.cantitate * a.pret_achizitie) FROM A_B_ACHIZITIE a WHERE a.cod_st = s.cod_statie)
    FROM A_B_COMPANIE c
    JOIN A_B_STATIE s
    ON c.cod = s.cod_companie
    ORDER BY c.cod;
/
