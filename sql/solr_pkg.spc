CREATE OR REPLACE PACKAGE SOLR_PKG
/** 
* <ul>
* <li>Package fuer die Aufbereitung und Syntaxcheck der Suchanfrage, Filter und Facets</li>
* <li>Verantwortlich fuer die Kommunikation mit Apache Solr und Parsing des XML Antwortdokumentes</li>
* <li>Extrahiert Primaerschluesselliste oder Facetliste aus Apache Solrs XML Antwortdokument in eine PL/SQL Tabelle</li>
* <li>Benutzbar in SQL und in PL/SQL</li>
* </ul><br />
* Beispiel fuer Extrahierung Primaerschluesselliste
* <pre>SELECT 
*   *
* FROM 
*   TABLE(
*     SOLR_PKG.EXTRACT_RESULTS(
*       RESULTSET => SOLR_PKG.SEARCH(
*                      QUERY_CLAUSE => SOLR_PKG.BUILD_QUERY('h*'),
*                      FILTER_CLAUSE => SOLR_PKG.BUILD_FILTER('artikel_packeinheit','10'),
*                      FACET_CLAUSE => SOLR_PKG.BUILD_FACET('artikel_hersteller')
*                    )
*       )
*   )</pre>
* Beispiel fuer Extrahierung Facetliste
* <pre>SELECT
*   *
* FROM 
*   TABLE(
*     SOLR_PKG.EXTRACT_FACET(
*       RESULTSET => SOLR_PKG.SEARCH(
*                      QUERY_CLAUSE => SOLR_PKG.BUILD_QUERY('h*'),
*                      FILTER_CLAUSE => SOLR_PKG.BUILD_FILTER('artikel_packeinheit','10'),
*                      FACET_CLAUSE => SOLR_PKG.BUILD_FACET('artikel_hersteller')
*                    ),
*       FACET_FIELD => 'artikel_hersteller'
*     )
*   )</pre>
*/
 IS

    /** Raw Suchanfrage Syntaxcheck und Aufbereitung
    * <pre>  SELECT 
    *   SOLR_PKG.BUILD_QUERY('artikel_name:blei* AND artikel_preis:[10 TO 100]')
    *   FROM DUAL<pre />
    * erzeugt <pre>q=artikel_name:blei*%20AND%20artikel_preis:[10%20TO%20100]&<pre />
    * @param USER_QUERY Die Suchanfrage in <a target="_blank" href="http://wiki.apache.org/solr/SolrQuerySyntax">Apache Solr Query Syntax</a>
    * @return VARCHAR2 Die transformierte Suchanfrage enkodiert nach <a target="_blank" href="http://tools.ietf.org/html/rfc3986#section-2">RFC 3986</a>
    */
    FUNCTION BUILD_QUERY(USER_QUERY VARCHAR2) RETURN VARCHAR2;

    /** Aufbereitung Filter Klausel fuer Suchanfrage
    * <pre> SQL> SELECT 
    *   SOLR_PKG.BUILD_FILTER('artikel_hersteller','Oracle')
    * FROM DUAL;<pre />
    * erzeugt <pre>fq=+artikel_hersteller:"Oracle"&<pre />
    * @param FIELD_NAME Das Dokumentenfeld 
    * @param FIELD_VALUE Der zu filterne Feldert in field_name
    * @return Die transformierte Filter Klausel enkodiert nach <a target="_blank" href="http://tools.ietf.org/html/rfc3986#section-2">RFC 3986</a>
    * Suchanfrage kann ueber Hilfsfunktion <a target="_blank" href="solr_pkg.html#build_query(varchar2)">BUILD_QUERY</a> erstellt werden
    */
    FUNCTION BUILD_FILTER
    (
        FIELD_NAME  VARCHAR2,
        FIELD_VALUE VARCHAR2
    ) RETURN VARCHAR2;

    /** Aufbereitung Facet Klausel fuer Dokumentefeld
    * <pre> SELECT 
    *   SOLR_PKG.BUILD_FACET('artikel_hersteller')
    * FROM DUAL</pre>
    * erzeugt <pre>* facet.field=artikel_hersteller&</pre>
    * @param FIELD_NAME Das Dokumentenfeld 
    * @return Die transformierte Facet Klausel enkodiert nach <a target="_blank" href="http://tools.ietf.org/html/rfc3986#section-2">RFC 3986</a>
    */
    FUNCTION BUILD_FACET(FIELD_NAME VARCHAR2) RETURN VARCHAR2;

    /** Suchanfrage aus QUERY_CLAUSE, FILTER_CLAUSE und FACET_CLAUSE zusammensetzen und Suche ueber Apache Solr durchfuehren 
    * <pre> DELCARE
    *   XML_DOC XMLTYPE;
    * BEGIN
    *   XML_DOC := SOLR_PKG.SEARCH(
    *                QUERY_CLAUSE => SOLR_PKG.BUILD_QUERY('h*'),
    *                FILTER_CLAUSE => SOLR_PKG.BUILD_FILTER('artikel_packeinheit','10'),
    *                FACET_CLAUSE => SOLR_PKG.BUILD_FACET('artikel_hersteller')
    *              )
    * END;</pre>
    * @param QUERY_CLAUSE Suchanfrage in <a target="_blank"http://wiki.apache.org/solr/SolrQuerySyntax">Apache Solr Query Syntax</a>. 
    * Suchanfrage kann ueber Hilfsfunktion <a target="_blank" href="solr_pkg.html#build_query(varchar2)">BUILD_QUERY</a> erstellt werden.
    * @param FILTER_CLAUSE Filter Klausel entsprechend der Apache Solr Query Syntax.
    * Klausel kann ueber Hilfsfunktion <a target="_blank" href="solr_pkg.html#build_filter(varchar2,varchar2)">BUILD_FILTER</a> erstellt werden.
    * @param FACET_CLAUSE Facet Klausel entsprechend der Apache Solr Query Syntax
    * Klausel kann ueber Hilfsfunktion <a target="_blank" href="solr_pkg.html#extract_facet(xmltype,varchar2)">BUILD_FILTER</a> erstellt werden.
    * @return Apache Solr XML Antwortdokument als <a target="_blank" href="http://download.oracle.com/docs/cd/B28359_01/appdev.111/b28419/t_xml.htm#i1007914">XMLTYPE</a>
    * @throws 31011 <a target="_blank" href="http://download.oracle.com/docs/cd/B28359_01/server.111/b28278/e29250.htm#sthref9535">XML parsing failed</a>
    * @throws 29261-29276 <a target="_blank" href="http://download.oracle.com/docs/cd/B28359_01/server.111/b28278/e29250.htm#ORA-29250">UTL_HTTP Exceptions</a>
    */
    FUNCTION SEARCH
    (
        QUERY_CLAUSE  VARCHAR2,
        FILTER_CLAUSE VARCHAR2 DEFAULT NULL,
        FACET_CLAUSE  VARCHAR2 DEFAULT NULL
    ) RETURN XMLTYPE;

    /** Primaerschluesselliste aus Apache Solr XML Antwortdokument extrahieren
    * <pre> SELECT 
    *   *
    * FROM 
    *   TABLE(
    *     SOLR_PKG.EXTRACT_RESULTS(
    *       :XML_DOC               
    *       )
    *   )</pre>
    * @param RESULTSET Apache Solr XML Antwortdokument als <a target="_blank" href="http://download.oracle.com/docs/cd/B28359_01/appdev.111/b28419/t_xml.htm#i1007914">XMLTYPE</a>
    * @return SOLR_RESULT_ROW_LIST absteigend nach Relevanz sortiert
    * @throws 31011 <a target="_blank" href="http://download.oracle.com/docs/cd/B28359_01/server.111/b28278/e29250.htm#sthref9535">XML parsing failed</a>
    */
    FUNCTION EXTRACT_RESULTS(RESULTSET XMLTYPE) RETURN SOLR_RESULT_ROW_LIST;

    /** Facet zu Dokumentenfeld aus Apache Solr XML Antwortdokument extrahieren
    * <pre> SELECT
    *   *
    * FROM 
    *   TABLE(
    *     SOLR_PKG.EXTRACT_FACET(
    *       :XML_DOC
    *     )
    *   )</pre>
    * @param RESULTSET Apache Solr XML Antwortdokument als <a target="_blank" href="http://download.oracle.com/docs/cd/B28359_01/appdev.111/b28419/t_xml.htm#i1007914">XMLTYPE</a>
    * @param FACET_FIELD Facetiertes Dokumentenfeld
    * @return SOLR_FACET_ROW_LIST absteigend nach Haeufigkeit sortiert
     @throws 31011 <a target="_blank" href="http://download.oracle.com/docs/cd/B28359_01/server.111/b28278/e29250.htm#sthref9535">XML parsing failed</a>
    */
    FUNCTION EXTRACT_FACET
    (
        RESULTSET   XMLTYPE,
        FACET_FIELD VARCHAR2
    ) RETURN SOLR_FACET_ROW_LIST;

END SOLR_PKG;
/

