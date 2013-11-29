

create public synonym solr_globals_pkg for solr_globals_pkg;
create public synonym solr_pkg for solr_pkg;
create public synonym solr_dataimport_pkg for solr_dataimport_pkg;

grant execute on solr_pkg to public;
grant execute on solr_dataimport_pkg to public; -- more restrictiveness in production, please