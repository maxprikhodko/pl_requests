set serveroutput on size 1000000

prompt ----------------------------------------------;
prompt -- Installing PL_REQUESTS PLJSON extension  --;
prompt ----------------------------------------------;

@@../src/types/ext/pl_request_json.tps
@@../src/types/ext/pl_request_json.tpb
