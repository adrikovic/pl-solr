CREATE OR REPLACE PACKAGE BODY SOLR_PKG AS

    FUNCTION CHECK_SYNTAX(USER_QUERY VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        --Pruefen der Query Syntax http://lucene.apache.org/java/3_1_0/queryparsersyntax.html
        --Dummy
        RETURN USER_QUERY;
    END;

    FUNCTION URL_ENCODE(P_STRING VARCHAR2) RETURN VARCHAR2 IS
        L_STRING VARCHAR2(4000);
    BEGIN
        --Encoding http://tools.ietf.org/html/rfc3986#section-2
        --Dummy
        L_STRING := P_STRING;
        L_STRING := REPLACE(L_STRING, '&', '%26');
        L_STRING := REPLACE(L_STRING, ' ', '%20');
        RETURN L_STRING;
    END;

    ---------------------------------------
    ----------- Spezizifikation -----------
    ---------------------------------------

    FUNCTION BUILD_QUERY(USER_QUERY VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN 'q=' || URL_ENCODE(USER_QUERY) || '&';
    END;

    FUNCTION BUILD_FILTER
    (
        FIELD_NAME  VARCHAR2,
        FIELD_VALUE VARCHAR2
    ) RETURN VARCHAR2 IS
    BEGIN
        RETURN 'fq=' || URL_ENCODE(FIELD_NAME) || URL_ENCODE(':"' || FIELD_VALUE || '"') || '&';
    END;

    FUNCTION BUILD_FACET(FIELD_NAME VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN 'facet.field=' || URL_ENCODE(FIELD_NAME) || '&';
    END;

    FUNCTION SEARCH
    (
        QUERY_CLAUSE  VARCHAR2,
        FILTER_CLAUSE VARCHAR2 DEFAULT NULL,
        FACET_CLAUSE  VARCHAR2 DEFAULT NULL
    ) RETURN XMLTYPE IS
        -- lokale Variablen
        SERVLET              VARCHAR2(50) := SOLR_GLOBALS_PKG.ENDPOINT || '/select'; --Endpoint aus SOLR_GLOBALS_PKG holen. Zentrale Konfiguration
        FACET_CLAUSE_CHECKED VARCHAR2(4000) := NULL;
        XML                  XMLTYPE;
        URL                  HTTPURITYPE;
    BEGIN
        IF FACET_CLAUSE IS NOT NULL THEN
            --facet=true ist notwendig, um Facetierung in Apache Solr zu aktivieren
            --sollte nur aktiviert werden, wenn Facets angefordert werden
            --schont Ressourcen
            FACET_CLAUSE_CHECKED := 'facet=true&' || FACET_CLAUSE;
        END IF;
    
        --URL konstruieren
        URL := HTTPURITYPE(SERVLET || '?' || QUERY_CLAUSE || FILTER_CLAUSE || FACET_CLAUSE_CHECKED);
    
        --Call durchfuehren
        XML := URL.GETXML();
        RETURN XML;
    END;

    FUNCTION EXTRACT_RESULTS(RESULTSET XMLTYPE) RETURN SOLR_RESULT_ROW_LIST IS
        -- lokale Variablen
        LIST SOLR_RESULT_ROW_LIST;
    BEGIN
        -- alle Primaerschluessel extrahieren und in PL/SQL Tabelle ueberfuehren
        SELECT EXTRACTVALUE(VALUE(T), '/doc/str[@name="artikel_id"]') BULK COLLECT
        INTO LIST
        FROM TABLE(XMLSEQUENCE(EXTRACT(RESULTSET, '/response/result/doc'))) T;
        RETURN LIST;
    END;

    FUNCTION EXTRACT_FACET
    (
        RESULTSET   XMLTYPE,
        FACET_FIELD VARCHAR2
    ) RETURN SOLR_FACET_ROW_LIST IS
        -- lokale Variablen
        LIST SOLR_FACET_ROW_LIST;
    BEGIN
        -- alle Faceteintraege zum Dokumentenfeld extrahieren und in PL/SQL Tabelle ueberfuehren
        SELECT SOLR_FACET_ROW(EXTRACTVALUE(VALUE(T), '/int/@name'), EXTRACTVALUE(VALUE(T), '/int')) BULK COLLECT
        INTO LIST
        FROM TABLE(XMLSEQUENCE(EXTRACT(RESULTSET,
                                       '/response/lst[@name="facet_counts"]/lst[@name="facet_fields"]/lst[@name="' ||
                                       FACET_FIELD || '"]/int'))) T;
        RETURN LIST;
    END;

END SOLR_PKG;
/

