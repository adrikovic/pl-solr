

-- Schema erstellen
create user PLSOLR
  default tablespace USERS
  temporary tablespace TEMP
  profile DEFAULT
  password expire
  account lock;
/

-- Grant/Revoke
grant connect to PLSOLR;
/

grant resource to PLSOLR;
/

grant create public synonym to PLSOLR;
/

-- Zugriff auf Apache Solr über HTTP zulassen
DECLARE
    GRANTEE  VARCHAR2(100) := 'PLSOLR';
    ACL_NAME VARCHAR2(100) := 'utl_solr_http.xml';
    ACL_HOST VARCHAR2(100);
    ACL_PORT PLS_INTEGER;

BEGIN
    ACL_HOST := SOLR_GLOBALS_PKG.HOST;
    ACL_PORT := SOLR_GLOBALS_PKG.PORT;

    BEGIN
        DBMS_NETWORK_ACL_ADMIN.DROP_ACL(ACL_NAME);
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(ACL         => ACL_NAME,
                                      DESCRIPTION => 'HTTP Solr Access',
                                      PRINCIPAL   => GRANTEE,
                                      IS_GRANT    => TRUE,
                                      PRIVILEGE   => 'connect');

    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL       => ACL_NAME,
                                         PRINCIPAL => GRANTEE,
                                         IS_GRANT  => TRUE,
                                         PRIVILEGE => 'resolve');

    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(ACL => ACL_NAME, HOST => ACL_HOST, LOWER_PORT => ACL_PORT);

    COMMIT;
END;
/