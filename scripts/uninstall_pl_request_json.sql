set serveroutput on size 1000000

prompt ------------------------------------------------;
prompt -- Uninstalling PL_REQUESTS PLJSON extension  --;
prompt ------------------------------------------------;

declare
  type typ_statements is varray(32)
                      of varchar2(512);
  
  l_statements typ_statements := typ_statements(
      'drop type body pl_request_json'
    , 'drop type pl_request_json'
  );
begin
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
