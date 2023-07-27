create or replace PACKAGE util AS
                       
  PROCEDURE ADD_EMPLOYEE(
                    p_first_name IN VARCHAR2,
                    p_last_name IN VARCHAR2,
                    p_email IN VARCHAR2,
                    p_phone_number IN VARCHAR2,
                    p_hire_date IN DATE DEFAULT trunc(sysdate, 'dd'),
                    p_job_id IN VARCHAR2,
                    p_salary IN NUMBER,
                    p_commission_pct IN VARCHAR2 DEFAULT NULL,
                    p_manager_id IN NUMBER DEFAULT 100,
                    p_department_id IN NUMBER);
                    
  PROCEDURE FIRE_AN_EMPLOYEE(
                    P_EMPLOYEE_ID IN NUMBER);
                    
  PROCEDURE CHANGE_ATTRIBUTE_EMPLOYEE(
                    P_EMPLOYEE_ID IN NUMBER,
                    p_first_name IN VARCHAR2 DEFAULT NULL,
                    p_last_name IN VARCHAR2 DEFAULT NULL,
                    p_email IN VARCHAR2 DEFAULT NULL,
                    p_phone_number IN VARCHAR2 DEFAULT NULL,
                    p_job_id IN VARCHAR2 DEFAULT NULL,
                    p_salary IN NUMBER DEFAULT NULL,
                    p_commission_pct IN VARCHAR2 DEFAULT NULL,
                    p_manager_id IN NUMBER DEFAULT NULL,
                    p_department_id IN NUMBER DEFAULT NULL);
                    
                    
END util;

------------------------------------------------------------------------------

create or replace PACKAGE BODY util AS


    PROCEDURE check_work_time IS
  BEGIN
  
        IF to_char(SYSDATE,'HH24:MI:SS') NOT BETWEEN '08:00:00' AND '18:00:00' OR
            to_char(SYSDATE,'DY','NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT','SUN')
        THEN
--            dbms_output.put_line(to_char(SYSDATE,'HH24:MI:SS') || ' ERROR!!! NOT WORK TIME');
            raise_application_error(-20001,'Ви можете додавати нового співробітника лише в робочий час');
        END IF;
  
  END check_work_time;

---------------------------------------------------------

PROCEDURE ADD_EMPLOYEE(
                    p_first_name IN VARCHAR2,
                    p_last_name IN VARCHAR2,
                    p_email IN VARCHAR2,
                    p_phone_number IN VARCHAR2,
                    p_hire_date IN DATE DEFAULT trunc(sysdate, 'dd'),
                    p_job_id IN VARCHAR2,
                    p_salary IN NUMBER,
                    p_commission_pct IN VARCHAR2 DEFAULT NULL,
                    p_manager_id IN NUMBER DEFAULT 100,
                    p_department_id IN NUMBER) 
    IS
        V_EMPLOYEE_ID NUMBER;
        V_EXISTS NUMBER;
        V_MIN NUMBER;
        V_MAX NUMBER;
        
BEGIN
LOG_UTIL.LOG_START('ADD EMPLOYEE');

        BEGIN
            check_work_time; --LINE 22
        END;

        BEGIN
            SELECT 1
            INTO V_EXISTS
            FROM JOBS J
            WHERE J.JOB_ID = P_JOB_ID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий код посади');
        END;

        BEGIN
            SELECT 1
            INTO V_EXISTS
            FROM DEPARTMENTS D
            WHERE D.DEPARTMENT_ID = P_DEPARTMENT_ID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий ідентифікатор відділу');
        END;

        BEGIN
            SELECT J.MIN_SALARY, J.MAX_SALARY
            INTO V_MIN, V_MAX
            FROM JOBS J
            WHERE J.JOB_ID = P_JOB_ID;
        IF P_SALARY NOT BETWEEN V_MIN AND V_MAX
        THEN 
            RAISE_APPLICATION_ERROR(-20001,'Введено неприпустиму заробітну плату для даного коду посади');
        END IF;
        END;

        BEGIN
            SELECT MAX(EM.EMPLOYEE_ID)+1
            INTO V_EMPLOYEE_ID
            FROM EMPLOYEES EM;
                INSERT INTO EMPLOYEES(
                EMPLOYEE_ID, 
                FIRST_NAME, 
                LAST_NAME, 
                EMAIL, 
                PHONE_NUMBER, 
                HIRE_DATE, 
                JOB_ID, 
                SALARY, 
                COMMISSION_PCT, 
                MANAGER_ID, 
                DEPARTMENT_ID)
                VALUES(V_EMPLOYEE_ID, 
                p_first_name, 
                p_last_name, 
                p_email, 
                p_phone_number, 
                p_hire_date, 
                p_job_id, 
                p_salary, 
                p_commission_pct, 
                p_manager_id, 
                p_department_id);
            COMMIT;
            dbms_output.put_line('Співробітник' || p_first_name ||' ' || p_last_name ||', КОД ПОСАДИ:' || p_job_id ||', ІД ДЕПАРТАМЕНТУ:' || p_department_id || 'успішно додано до системи');
        END;
    
    LOG_UTIL.LOG_FINISH('ADD EMPLOYEE');

    EXCEPTION
    WHEN OTHERS THEN 
    LOG_UTIL.LOG_ERROR(sqlerrm,'ADD EMPLOYEE');
    LOG_UTIL.LOG_FINISH('ADD EMPLOYEE');

END ADD_EMPLOYEE;

----------------------------------------------------------

PROCEDURE FIRE_AN_EMPLOYEE(P_EMPLOYEE_ID IN NUMBER)
IS V_EEMPLOYEE VARCHAR2(200);
    
BEGIN
    LOG_UTIL.LOG_START('FIRE AN EMPLOYEE');

    BEGIN
        CHECK_WORK_TIME;
    END;
    
    BEGIN
        SELECT EM.FIRST_NAME ||' '|| EM.LAST_NAME ||' '|| EM.JOB_ID ||' DEPARTMENT: '|| EM.DEPARTMENT_ID
        INTO V_EEMPLOYEE
        FROM EMPLOYEES EM
        WHERE EM.EMPLOYEE_ID = P_EMPLOYEE_ID;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,'Переданий співробітник не існує');
    END;
    
    BEGIN
        DELETE FROM EMPLOYEES EM
        WHERE EM.EMPLOYEE_ID = P_EMPLOYEE_ID;
        COMMIT;
        dbms_output.put_line('Співробітник ' || V_EEMPLOYEE || ' видалено успішно');
    END;
    
    LOG_UTIL.LOG_FINISH('FIRE AN EMPLOYEE');
    
    EXCEPTION
    WHEN OTHERS THEN 
    LOG_UTIL.LOG_ERROR(sqlerrm,'FIRE AN EMPLOYEE');
    LOG_UTIL.LOG_FINISH('FIRE AN EMPLOYEE');

END FIRE_AN_EMPLOYEE;
    
-----------------------------------------------------------------  

PROCEDURE CHANGE_ATTRIBUTE_EMPLOYEE(
                    P_EMPLOYEE_ID IN NUMBER,
                    p_first_name IN VARCHAR2 DEFAULT NULL,
                    p_last_name IN VARCHAR2 DEFAULT NULL,
                    p_email IN VARCHAR2 DEFAULT NULL,
                    p_phone_number IN VARCHAR2 DEFAULT NULL,
                    p_job_id IN VARCHAR2 DEFAULT NULL,
                    p_salary IN NUMBER DEFAULT NULL,
                    p_commission_pct IN VARCHAR2 DEFAULT NULL,
                    p_manager_id IN NUMBER DEFAULT NULL,
                    p_department_id IN NUMBER DEFAULT NULL)
    IS
        V_STRING VARCHAR2(1000) DEFAULT NULL;
        V_EXISTS NUMBER;
        
BEGIN
    LOG_UTIL.LOG_START('CHANGE ATTRIBUTE EMPLOYEE');

        BEGIN
            check_work_time;
        END;

        BEGIN
            SELECT 1
            INTO V_EXISTS
            FROM EMPLOYEES EM
            WHERE EM.EMPLOYEE_ID = P_EMPLOYEE_ID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001,'Введено неіснуючий код співробітника');
        END;
        
        BEGIN
            IF p_first_name IS NOT NULL 
            THEN V_STRING:=V_STRING || 'FIRST_NAME=''' || p_first_name || ''',';
            END IF;
            IF p_last_name IS NOT NULL 
            THEN V_STRING:=V_STRING || 'last_name=''' || p_last_name || ''',';
            END IF;            
            IF p_email IS NOT NULL 
            THEN V_STRING:=V_STRING || 'email=' || p_email || ',';
            END IF;            
            IF p_phone_number IS NOT NULL 
            THEN V_STRING:=V_STRING || 'phone_number=' || p_phone_number || ',';
            END IF;            
            IF p_job_id IS NOT NULL 
            THEN V_STRING:=V_STRING || 'job_id=' || p_job_id || ',';
            END IF;            
            IF p_salary IS NOT NULL 
            THEN V_STRING:=V_STRING || 'salary=' || p_salary || ',';
            END IF;            
            IF p_commission_pct IS NOT NULL 
            THEN V_STRING:=V_STRING || 'commission_pct=' || p_commission_pct || ',';
            END IF;            
            IF p_manager_id IS NOT NULL 
            THEN V_STRING:=V_STRING || 'manager_id=' || p_manager_id || ',';
            END IF;            
            IF p_department_id IS NOT NULL 
            THEN V_STRING:=V_STRING || 'department_id=' || p_department_id || ',';
            END IF;                                
        END;

        BEGIN
            IF V_STRING IS NULL THEN 
                RAISE_APPLICATION_ERROR(-20001,'Відсутні дані для зміни');
            END IF;  
        END;
     
        BEGIN               
            V_STRING:=SUBSTR(V_STRING,1,LENGTH(V_STRING)-1);
            EXECUTE IMMEDIATE
                'update employees
                set '|| V_STRING ||'
                where employee_id = ' || P_EMPLOYEE_ID ;
            COMMIT;
            dbms_output.put_line('У співробітника ' || P_EMPLOYEE_ID || ' успішно оновлені атрибути');
        EXCEPTION
            WHEN OTHERS THEN 
                LOG_UTIL.LOG_ERROR(sqlerrm,'CHANGE ATTRIBUTE EMPLOYEE');
        END;
    
    LOG_UTIL.LOG_FINISH('CHANGE ATTRIBUTE EMPLOYEE');

    EXCEPTION
    WHEN OTHERS THEN 
    LOG_UTIL.LOG_ERROR(sqlerrm,'CHANGE ATTRIBUTE EMPLOYEE');
    LOG_UTIL.LOG_FINISH('CHANGE ATTRIBUTE EMPLOYEE');
    
END CHANGE_ATTRIBUTE_EMPLOYEE;
 
END util;