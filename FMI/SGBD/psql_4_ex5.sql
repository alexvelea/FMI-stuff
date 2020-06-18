/*    
    Definiţi un subprogram care obţine pentru fiecare nume de departament ziua din săptămână în
    care au fost angajate cele mai multe persoane, lista cu numele acestora, vechimea şi venitul lor
    lunar. Afişaţi mesaje corespunzătoare următoarelor cazuri:
    - într-un departament nu lucrează niciun angajat;
    - într-o zi din săptămână nu a fost nimeni angajat.
    Observaţii:
    a. Numele departamentului şi ziua apar o singură dată în rezultat.
    b. Rezolvaţi problema în două variante, după cum se ţine cont sau nu de istoricul joburilor angajaţilor.
*/


DECLARE

    FUNCTION day_of_the_week_name(p_week_day NUMBER)
    RETURN varchar2 IS
    BEGIN
        CASE p_week_day 
        WHEN 1 THEN return 'Monday';
        WHEN 2 THEN return 'Tuesday';
        WHEN 3 THEN return 'Wednesday';
        WHEN 4 THEN return 'Thursday';
        WHEN 5 THEN return 'Friday';
        WHEN 6 THEN return 'Saturday';
        WHEN 7 THEN return 'Sunday';
        ELSE return NULL;
        END CASE;
    END;

    PROCEDURE print_department_info(
        p_department_id IN EMP_VA.DEPARTMENT_ID%TYPE,
        p_week_day      IN NUMBER) IS
    BEGIN
        dbms_output.put_line('The most hires for department ' || p_department_id || ' were made on ' || day_of_the_week_name(p_week_day));
        FOR e IN (
            SELECT e.first_name, e.hire_date, (e.salary * (nvl(e.commission_pct, 0) + 1)) income
            FROM EMP_VA e
            WHERE department_id = p_department_id AND
                to_char(e.hire_date, 'D') = p_week_day
            ) LOOP
            dbms_output.put_line('   ' || e.first_name || ' ' || e.income || ' ' || e.hire_date);
        END LOOP;
    END;

    PROCEDURE solve_department(p_department_id EMP_VA.DEPARTMENT_ID%TYPE) IS
        v_week_day NUMBER(2);
    BEGIN
        SELECT week_day INTO v_week_day FROM (
            SELECT COUNT(*) cnt, TO_CHAR(e.HIRE_DATE, 'D') week_day
            FROM departments d 
            LEFT JOIN emp_va e ON d.department_id = e.department_id
            WHERE d.department_id=p_department_id
            GROUP BY TO_CHAR(e.HIRE_DATE, 'D')
            ORDER BY cnt DESC)
        WHERE ROWNUM = 1;
        
        IF v_week_day IS NULL THEN
            dbms_output.put_line('There were no hires for department ' || p_department_id);
        ELSE
            print_department_info(p_department_id, v_week_day);
        END IF;
        dbms_output.put_line('');
    END;
BEGIN
    FOR d IN (SELECT department_id FROM departments) LOOP
        solve_department(d.department_id);
    END LOOP;
END;


BEGIN
dbms_output.put_line(to_char('1', 'DAY'));
END;
    
SELECT d.department_id, TO_CHAR(e.HIRE_DATE, 'D')
FROM departments d 
LEFT JOIN emp_va e ON d.department_id = e.department_id
-- LEFT JOIN job_history jh ON d.department_id = jh.department_id
WHERE d.department_id = 50
GROUP BY  d.department_id, TO_CHAR(e.HIRE_DATE, 'D')
ORDER BY TO_CHAR(e.HIRE_DATE, 'D');