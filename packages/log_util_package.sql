create or replace PACKAGE LOG_UTIL AS 

    PROCEDURE LOG_START(p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL);
                       
    PROCEDURE LOG_FINISH(p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL);
                       
    PROCEDURE LOG_ERROR(p_sqlerrm     IN VARCHAR2,
                       p_proc_name  IN VARCHAR2,
                       p_text       IN VARCHAR2 DEFAULT NULL);
END LOG_UTIL;