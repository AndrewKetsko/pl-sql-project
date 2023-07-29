BEGIN
sys.dbms_scheduler.create_job(
    job_name => 'update_curr',
    job_type => 'PLSQL_BLOCK',
    job_action => 'begin UTIL.API_NBU_SYNC(); end;',
    start_date => SYSDATE,
    repeat_interval => 'FREQ=DAILY;BYHOUR=06;BYMINUTE=00',
    end_date => TO_DATE(NULL),
    job_class => 'DEFAULT_JOB_CLASS',
    enabled => TRUE,
    auto_drop => FALSE,
    comments => 'Оновлення курс валют');
END;
/

BEGIN
dbms_scheduler.disable(name=>'UPDATE_CURR', force => TRUE);
END;
/

BEGIN
dbms_scheduler.enable(name=>'UPDATE_CURR');
END;
/

