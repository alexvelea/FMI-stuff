ALTER TABLE MEMBER_VA
DROP COLUMN DISCOUNT;

/*  Adăugați în acest tabel coloana discount, care va reprezenta procentul de reducere aplicat pentru membrii, 
    în funcție de categoria din care fac parte aceștia */
ALTER TABLE MEMBER_VA
ADD DISCOUNT NUMBER(3,2) DEFAULT 0 NOT NULL;

/* Definirea categoriilor */
/*  - Categoria 1 (a împrumutat mai mult de 75% din titlurile existente)
    - Categoria 2 (a împrumutat mai mult de 50% din titlurile existente)
    - Categoria 3 (a împrumutat mai mult de 25% din titlurile existente)
    - Categoria 4 (altfel) */
    
/* Discount per categorie */
/*  - 10% pentru membrii din Categoria 1
    - 5% pentru membrii din Categoria 2
    - 3% pentru membrii din Categoria 3
    - nimic */

DECLARE
    target_member_id member_va.member_id%TYPE := &target_member_id;
    
    num_movies_total NUMBER(9);
    member_num_movies NUMBER(9);
    member_new_discount member_va.discount%TYPE;
BEGIN
    SELECT count(*) INTO :num_movies_total FROM TITLE;
    SELECT count(distinct title_id) INTO :member_num_movies FROM RENTAL WHERE MEMBER_ID = target_member_id;
    
    /* Gasim categoria membrului curent si punem discountul cum trebuie */
    CASE
    WHEN :member_num_movies / :num_movies_total >= 0.25 AND :member_num_movies / :num_movies_total < 0.50 THEN
        member_new_discount := 0.03;
    WHEN :member_num_movies / :num_movies_total >= 0.50 AND :member_num_movies / :num_movies_total < 0.75 THEN
        member_new_discount := 0.05;
    WHEN :member_num_movies / :num_movies_total >= 0.75 THEN
        member_new_discount := 0.75;
    ELSE
        member_new_discount := 0.00;
    END CASE;
    
    /* Updatam datele */
    UPDATE member_va x 
        SET x.discount=member_new_discount 
        WHERE x.member_id=target_member_id;
        
    /* Afisam mesajul de oroare daca trebuie */
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista membrul cu id-ul ' || target_member_id);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Actualizare efectuata cu succes! Noul discount: ' || member_new_discount);
    END IF;
END;