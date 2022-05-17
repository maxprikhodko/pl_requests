set serveroutput on size 1000000

prompt ------------------------------;
prompt -- Uninstalling PL_REQUESTS --;
prompt ------------------------------;

declare
  g_schema constant varchar2(64) := sys_context( 'userenv', 'current_schema' );

  cursor cur_extensions
  is
    select do.object_name
         , do.object_type
         , 'DROP '        ||
           do.object_type || ' ' ||
           do."OWNER"     || '.' ||
           do.object_name
           as stmnt
      from dba_objects do 
     where do."OWNER"     = g_schema
       and do.object_type = any ( 'TYPE', 'PACKAGE', 'TYPE BODY', 'PACKAGE BODY' )
       and do.object_name = any ( 'PL_REQUEST_JSON' )
    order by decode( do.object_type
                   , 'PACKAGE BODY', 10
                   , 'TYPE BODY'   , 20
                   , 'PACKAGE'     , 30  
                   , 'TYPE'        , 40
                   , 0 );
  
  type typ_statements is varray(32)
                      of varchar2(512);
  type typ_extensions is table of cur_extensions%ROWTYPE;
  
  l_extensions typ_extensions;
  l_statements typ_statements := typ_statements(
      'drop type body pl_request'
    , 'drop package body pl_requests'
    , 'drop package body pl_requests_helpers'
    , 'drop type pl_request'
    , 'drop package pl_requests'
    , 'drop package pl_requests_helpers'
    , 'drop type pl_requests_http_headers'
    , 'drop type pl_requests_http_header'
  );
begin
  --
  -- Drop some pl_requests extensions if they exist
  --
  dbms_output.put_line( 'Removing extensions...' );
  open cur_extensions;
  fetch cur_extensions
    bulk collect into l_extensions;
  close cur_extensions;

  if l_extensions.count > 0
  then
    for i in l_extensions.first .. l_extensions.last
    loop
      begin
        execute immediate l_extensions(i).stmnt;
      exception
        when OTHERS then
          dbms_output.put_line( 'Statement "' || l_extensions(i).stmnt || '" failed: ' || sqlerrm );
          continue;
      end;
    end loop;
  else
    dbms_output.put_line( 'No known extensions found' );
  end if;

  --
  -- Drop pl_requests
  --
  dbms_output.put_line( 'Removing core objects...' );
  for i in l_statements.first .. l_statements.last
  loop
    begin
      execute immediate l_statements(i);
    exception
      when OTHERS then
        dbms_output.put_line( 'Statement "' || l_statements(i) || '" failed: ' || sqlerrm );
        continue;
    end;
  end loop;
end;
/
