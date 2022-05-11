set serveroutput on size 1000000

prompt ----------------------------;
prompt -- Installing PL_REQUESTS --;
prompt ----------------------------;

-- Common types
@@src/types/pl_request_header.typ
@@src/types/pl_request_headers.typ

-- Specs
@@src/packages/pl_requests_helpers.pks
@@src/packages/pl_requests.pks
@@src/types/pl_request.tps

-- Bodies
@@src/packages/pl_requests_helpers.pkb
@@src/packages/pl_requests.pkb
@@src/types/pl_request.tpb
