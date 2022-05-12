set serveroutput on size 1000000

prompt ----------------------------------------------;
prompt -- Dropping public synonyms for PL_REQUESTS --;
prompt ----------------------------------------------;

declare
  c_schema constant varchar2(64) := sys_context( 'userenv', 'current_schema' );
  l_test            number       := 0;
  
  cursor cur_check( p_name    varchar2
                  , p_synonym varchar2
                              default null )
  is
    select sign(count(1))
      from sys.dba_objects do
    left join sys.dba_synonyms ds
      on  ds.table_owner  = do."OWNER"
      and ds.table_name   = p_name
      and ds."OWNER"      = 'PUBLIC'
      and ds.synonym_name = nvl( p_synonym, p_name )
     where do.object_name = p_name
       and do."OWNER"     = c_schema
       and do.object_type = any ( 'PACKAGE', 'TYPE', 'PROCEDURE', 'FUNCTION' )
       and ds.synonym_name is not null;
       
  type typ_objects is varray(32)
                   of varchar2(32);
  
  l_objects typ_objects := typ_objects(
      'PL_REQUESTS_HTTP_HEADER'
    , 'PL_REQUESTS_HTTP_HEADERS'
    , 'PL_REQUESTS_HELPERS'
    , 'PL_REQUESTS'
    , 'PL_REQUEST'
    , 'PL_REQUEST_JSON'
  );
begin
  for i in l_objects.first .. l_objects.last
  loop
    open cur_check( l_objects(i) );
    fetch cur_check into l_test;
    close cur_check;
    
    if l_test > 0
    then
      begin
        execute immediate 'drop public synonym ' || l_objects(i);
      exception
        when OTHERS then
          dbms_output.put_line( 'Failed for object "' || c_schema || '"."' || l_objects(i) || '"' || sqlerrm );
          continue;
      end;
    end if;
  end loop;
end;
/

