create or replace PACKAGE LOG_UTIL AS 

    PROCEDURE LOG_START(p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL);
                       
    PROCEDURE LOG_FINISH(p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL);
                       
    PROCEDURE LOG_ERROR(p_sqlerrm     IN VARCHAR2,
                       p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL);
END LOG_UTIL;

------------------------------------------------------------------------------

create or replace PACKAGE BODY LOG_UTIL AS

---------------------------------------------------

    PROCEDURE to_log(p_appl_proc IN VARCHAR2,
                    p_message IN VARCHAR2) IS
    PRAGMA autonomous_transaction;
    BEGIN
        INSERT INTO logs(id, appl_proc, message)
        VALUES(log_seq.NEXTVAL, p_appl_proc, p_message);
        COMMIT;
    END to_log;
    
-----------------------------------------------------

  PROCEDURE LOG_START(p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL) IS
                       V_TEXT VARCHAR2(150);
  BEGIN
        IF P_TEXT IS NULL
        THEN V_TEXT:='Старт логування, назва процесу = ' || P_PROC_NAME;
        ELSE V_TEXT:=P_TEXT;
        END IF;
    TO_LOG(p_appl_proc => p_proc_name, p_message => V_text);
  END LOG_START;

----------------------------------------------------

  PROCEDURE LOG_FINISH(p_proc_name  IN VARCHAR2,
                        p_text       IN VARCHAR2 DEFAULT NULL) IS
                       V_TEXT VARCHAR2(150);
  BEGIN
        IF P_TEXT IS NULL
        THEN V_TEXT:='Завершення логування, назва процесу = ' || P_PROC_NAME;
        ELSE V_TEXT:=P_TEXT;
        END IF;
    TO_LOG(p_appl_proc => p_proc_name, p_message => V_text);
  END LOG_FINISH;
  
----------------------------------------------------------

  PROCEDURE LOG_ERROR(p_sqlerrm     IN VARCHAR2,
                       p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL) IS
                       V_TEXT VARCHAR2(500);
  BEGIN
        IF P_TEXT IS NULL
        THEN V_TEXT:='В процедурі ' || p_proc_name || ' сталася помилка. ' || p_sqlerrm;
        ELSE V_TEXT:=P_TEXT;
        END IF;
    TO_LOG(p_appl_proc => p_proc_name, p_message => V_text);
  END LOG_ERROR;
  
---------------------------------------------------------------

END LOG_UTIL;