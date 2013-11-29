CREATE OR REPLACE PACKAGE BODY SOLR_DATAIMPORT_PKG AS

    /*
    * Querystring in P_QUERY liegt in der Form: "select?q=sucbegriff&fq=...&facet..." vor.
    * Endpunt von Apache Solr ist in Package SOLR_GLOBALS_PKG definiert.
    * HTTP GET an Apache Solr mit P_QUERY absetzen und Ergebnis an Aufrufer zur?ckgeben.
    */
    FUNCTION MAKE_REQUEST(P_QUERY VARCHAR2 DEFAULT NULL) RETURN XMLTYPE IS
    BEGIN
        RETURN HTTPURITYPE(SOLR_GLOBALS_PKG.ENDPOINT || '/' || P_QUERY).GETXML();
    END;

    /*
    * Delegiert an FUNCTION MAKE_REQUEST. R?ckgabe muss bei einer Funktion einer 
    * Variable zugewiesen werden, sonst ist ein PL/SQL Comiler Fehler die Folge. 
    * Prozedur soll da eingesetzt werden, wo die R?ckgabe irrelevant ist.
    */
    PROCEDURE MAKE_REQUEST(P_QUERY VARCHAR2 DEFAULT NULL) IS
        L_NULL XMLTYPE;
    BEGIN
        L_NULL := MAKE_REQUEST(P_QUERY);
    END;

    /*
    * Servlet des Data Import Handlers und Beginn des Querystring erstellen
    */
    FUNCTION DATAIMPORT(P_CMD VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN 'dataimport?command=' || P_CMD;
    END;

    ---------------------------------------
    ----------- Spezizifikation -----------
    ---------------------------------------

    FUNCTION STATUS RETURN SOLR_CORE_STATUS_LIST IS
        LIST  SOLR_CORE_STATUS_LIST;
        L_XML XMLTYPE;
    BEGIN
        -- XML Antwortdokument holen
        L_XML := MAKE_REQUEST(DATAIMPORT('status'));
    
        -- alle Key Value Paare extrahieren und in PL/SQL Tabelle ?berf?hren
        SELECT SOLR_CORE_STATUS(EXTRACTVALUE(VALUE(E), '//str/@name'), EXTRACTVALUE(VALUE(E), '//str')) BULK COLLECT
        INTO LIST
        FROM TABLE(XMLSEQUENCE(EXTRACT(L_XML, '/Results/str'))) E
        WHERE EXISTSNODE(VALUE(E), '//str/text()') = 1; -- nur XML Knoten beachten, die im "Value" einen Wert haben
    
        RETURN LIST;
    END;

    PROCEDURE ABORT IS
    BEGIN
        -- 'dataimport?command=abort'
        MAKE_REQUEST(DATAIMPORT('abort'));
    END;

    PROCEDURE FULL_IMPORT IS
    BEGIN
        -- 'dataimport?command=full-import'
        MAKE_REQUEST(DATAIMPORT('full-import'));
    END;

    PROCEDURE DELTA_IMPORT IS
    BEGIN
        -- 'dataimport?command=delta-import'
        MAKE_REQUEST(DATAIMPORT('delta-import'));
    END;

END SOLR_DATAIMPORT_PKG;
/

