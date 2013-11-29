CREATE OR REPLACE PACKAGE SOLR_DATAIMPORT_PKG
/**
* Package kontrolliert <a target="_blank" href="http://wiki.apache.org/solr/DataImportHandler">Data Import Handler</a> und ermoeglicht eine Indexaktualisierung ueber Prozeduren. 
* <strong>Achtung:</strong> Package folgt nicht transaktionaler Semantik.<br />
* Einsatz in Trigger moeglich, um eine zeitnahe Aktualisierung zu erreichen. <br />
* Beispiel fuer Trigger
* <pre> CREATE OR REPLACE TRIGGER ARTIKEL_TRG
*   AFTER INSERT OR UPDATE OR DELETE ON ARTIKEL
* DECLARE
*   STATUS VARCHAR2(10);
* BEGIN
*   SELECT 
*     VALUE INTO STATUS 
*   FROM 
*     TABLE(SOLR_DATAIMPORT_PKG.STATUS) 
*       WHERE KEY = 'Status';
* 
*   IF STATUS = SOLR_DATAIMPORT_PKG.IDLE THEN
*     SOLR_DATAIMPORT_PKG.DELTA_IMPORT;
*   END IF;
* END ARTIKEL_TRG</pre>
*/
 IS

    -- wartend
    IDLE CONSTANT VARCHAR2(10) := 'idle';

    -- beschaeftigt
    BUSY CONSTANT VARCHAR2(10) := 'busy';

    /** Status des Data Import Handler abrufen<br /> 
    * Nutzbar in SQL und PL/SQL<br />
    * Ergebnis in SQL: 
    * <pre> SELECT * FROM TABLE(SOLR_DATAIMPORT_PKG.STATUS);
	* 
	* KEY                               VALUE
    * --------------------------------- -----------------------------
    * Status                            busy
    * Command                           status
    * Import Response                   A command is still running...
    * Time Elapsed                      0:0:6.250
    * Total Requests made to DataSource 1
    * Total Rows Fetched                77000
    * Total Documents Processed         77000
    * Total Documents Skipped           0
    * Full Dump Started                 2011-07-09 03:43:41</pre>
    * @return SOLR_CORE_STATUS_LIST 
    */
    FUNCTION STATUS RETURN SOLR_CORE_STATUS_LIST;

    /** nur PL/SQL: ausfuehrendes Kommando abbrechen, sofern eines aktiv ist
    */
    PROCEDURE ABORT;

    /** nur PL/SQL: Indexneuerzeugung starten 
    */
    PROCEDURE FULL_IMPORT;

    /** nur PL/SQL: inkrementelle Aktualisierung starten
    */
    PROCEDURE DELTA_IMPORT;

END SOLR_DATAIMPORT_PKG;
/

