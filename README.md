PL/Solr 
=====

PL/Solr is an prototypical PL/SQL interface for Apache Solr.

## Installation ##

1. Execute sql script sql/dba_create_user_and_grants.sql as SYSDBA. Schema PLSOLR and necessary roles and acl's will be created.

2. Execute script sql/install.sql as user PLSOLR. PL/SQL packages and user defined types will be created.

3. Setup an external Apache Solr instance.

4. Replace default Apache Solr configuration with provided configuration from  solr/*

5. Put ojdbc6.jar in Apache Solr's classpath


####Query Solr with sql:####
<pre>
 SELECT
   *
 FROM
   TABLE(
     SOLR_PKG.EXTRACT_RESULTS(
       RESULTSET => SOLR_PKG.SEARCH(
                      QUERY_CLAUSE => SOLR_PKG.BUILD_QUERY('h*'),
                      FILTER_CLAUSE => SOLR_PKG.BUILD_FILTER('artikel_packeinheit','10'),
                      FACET_CLAUSE => SOLR_PKG.BUILD_FACET('artikel_hersteller')
                    )
       )
   )
</pre>

####Search result with facet:####

<pre>
 SELECT
   *
 FROM
   TABLE(
     SOLR_PKG.EXTRACT_FACET(
       RESULTSET => SOLR_PKG.SEARCH(
                      QUERY_CLAUSE => SOLR_PKG.BUILD_QUERY('h*'),
                      FILTER_CLAUSE => SOLR_PKG.BUILD_FILTER('artikel_packeinheit','10'),
                      FACET_CLAUSE => SOLR_PKG.BUILD_FACET('artikel_hersteller')
                    ),
       FACET_FIELD => 'artikel_hersteller'
     )
   )
</pre>

####Work with raw Solr xml response in PL/SQL blocks:####

<pre>
 DELCARE
   XML_DOC XMLTYPE;
 BEGIN
   XML_DOC := SOLR_PKG.SEARCH(
                QUERY_CLAUSE => SOLR_PKG.BUILD_QUERY('h*'),
                FILTER_CLAUSE => SOLR_PKG.BUILD_FILTER('artikel_packeinheit','10'),
                FACET_CLAUSE => SOLR_PKG.BUILD_FACET('artikel_hersteller')
              )
 END;
</pre>

####Run delta imports with Solr's Data Import Handler:####

<pre>
 CREATE OR REPLACE TRIGGER ARTIKEL_TRG
   AFTER INSERT OR UPDATE OR DELETE ON ARTIKEL
 DECLARE
   STATUS VARCHAR2(10);
 BEGIN
   SELECT
     VALUE INTO STATUS
   FROM
     TABLE(SOLR_DATAIMPORT_PKG.STATUS)
       WHERE KEY = 'Status';
   IF STATUS = SOLR_DATAIMPORT_PKG.IDLE THEN
     SOLR_DATAIMPORT_PKG.DELTA_IMPORT;
   END IF;
 END ARTIKEL_TRG
</pre>


####Retrieve status of Solr's Data Import Handler:####

<pre>
 SELECT * FROM TABLE(SOLR_DATAIMPORT_PKG.STATUS);
 
 KEY                               VALUE
 --------------------------------- -----------------------------
 Status                            busy
 Command                           status
 Import Response                   A command is still running...
 Time Elapsed                      0:0:6.250
 Total Requests made to DataSource 1
 Total Rows Fetched                77000
 Total Documents Processed         77000
 Total Documents Skipped           0
 Full Dump Started                 2011-07-09 03:43:41
</pre>


