CREATE OR REPLACE PACKAGE SOLR_GLOBALS_PKG
/**
* Globale Konfiguration fuer den Einsatz in <a href="solr_pkg.html">SOLR_PKG</a> und <a href="solr_dataimport_pkg.html">SOLR_DATAIMPORT_PKG</a>.
* ENDPOINT kann direkt verwendet werden, um einen HTTP Aufruf durchzufuehren.
*/
 IS

    -- Serverhost von Apache Solr 
    HOST CONSTANT VARCHAR2(100) := 'localhost';

    -- Serverport von Apache Solr 
    PORT CONSTANT NUMBER := 8080;

    -- Apache Solr Servlet
    SERVLET CONSTANT VARCHAR2(100) := 'solr';

    --Endpunkt der Apache Solr Instanz
    ENDPOINT CONSTANT VARCHAR2(100) := HOST || ':' || PORT || '/' || SERVLET;

END SOLR_GLOBALS_PKG;
/

