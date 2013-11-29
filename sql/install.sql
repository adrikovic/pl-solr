set define off
spool install.log

prompt
prompt Creating type SOLR_CORE_STATUS
prompt ==============================
prompt
@@solr_core_status.tps
prompt
prompt Creating type SOLR_CORE_STATUS_LIST
prompt ===================================
prompt
@@solr_core_status_list.tps
prompt
prompt Creating package SOLR_DATAIMPORT_PKG
prompt ====================================
prompt
@@solr_dataimport_pkg.spc
prompt
prompt Creating package SOLR_GLOBALS_PKG
prompt =================================
prompt
@@solr_globals_pkg.spc
prompt
prompt Creating type SOLR_FACET_ROW
prompt ============================
prompt
@@solr_facet_row.tps
prompt
prompt Creating type SOLR_FACET_ROW_LIST
prompt =================================
prompt
@@solr_facet_row_list.tps
prompt
prompt Creating type SOLR_RESULT_ROW_LIST
prompt ==================================
prompt
@@solr_result_row_list.tps
prompt
prompt Creating package SOLR_PKG
prompt =========================
prompt
@@solr_pkg.spc
prompt
prompt Creating package body SOLR_DATAIMPORT_PKG
prompt =========================================
prompt
@@solr_dataimport_pkg.bdy
prompt
prompt Creating package body SOLR_PKG
prompt ==============================
prompt
@@solr_pkg.bdy
prompt
prompt Creating synonyms
prompt ==============================
prompt
@@synonyms.sql

spool off
