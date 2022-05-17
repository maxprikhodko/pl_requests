# PL_REQUESTS

A simple wrapper around UTL_HTTP for performing HTTP requests from database. Something like nodejs `axios` or python `requests`, but for pl/sql.

## Usage

This toolset brings kinda object-oriented style of working with HTTP requests by exposing two object types:

- PL_REQUEST \[[docs](./docs/PL_REQUEST.md)\]
- PL_REQUEST_JSON \[[docs](./docs/PL_REQUEST_JSON.md)\] (optional extension for handling JSON-based responses)

Please note that usage of this lib is relied on input/output parameter types, specifing named parameters in program unit callbacks (however, callback parameter names should be simple to remember) and sometimes it may require strict type casting (for example, `cast( null as pljson )` instead of `null` for `data` parameter in `pl_request_json.fetch_json` callback when it is specified directly, etc.).

Documentation on units not provided in [docs](./docs) can be found in source files (look for pldoc comments).

### Setting Wallet

Wallet configuration will be needed for communication with HTTPS servers. For this toolset it can be set with 3 approaches:

1. With `UTL_HTTP.SET_WALLET( path in varchar2, password in varchar2 default null )` procedure. Wallet will be set for all current session requests. Setting `wallet_path` and `wallet_password` properties for `pl_request` instance **won't be needed while current session global wallet is valid for communication with configured service**. 
2. With `pl_requests.session_wallet( wallet_path in varchar2, wallet_password in varchar2 default null )` procedure. It does the same work as first approach, but you will be able to get recent wallet path set with this procedure with `pl_requests.session_wallet return varchar2` function. Setting `wallet_path` and `wallet_password` properties for `pl_request` instance **won't be needed while current session global wallet is valid for communication with configured service**. 
3. With configuring `wallet_path` and `wallet_password` (optional) properties during creation of `pl_request` instance. If `wallet_path` was provided, each request will create local request context with `UTL_HTTP.CREATE_REQUEST_CONTEXT` and destroy it with `UTL_HTTP.DESTROY_REQUEST_CONTEXT` after completion.

### Base functionality

``` sql
declare
  myService       pl_request;
  response_status number;
  response_body   varchar2(4000);
begin
  -- API service access instance configuration
  myService := pl_request( 
      base_url        => 'https://host/api/v1'
    , wallet_path     => 'file:/wallet_path'
    , wallet_password => 'wallet_password'
    , mime_type       => 'application/json'  -- Default mime type in content-type header for request data sent in body
  );
  
  -- Set headers which will be sent with any request
  myService.set_header( 'Accept', 'application/json' );
  myService.set_header( 'X-Api-Key', 'service secret api key' );
  
  -- Example: execute GET http request
  -- GET https://host/api/v1/items?item=1234
  myService.request( 
      method => 'GET'
    , url    => '/items?item=1234'
    , status => response_status
    , body   => response_body 
  );
  
  -- Process response
  if response_status = 200 
  then
    dbms_output.put_line( 'Success' );
    dbms_output.put_line( 'Response body: ' || response_body );
  else
    dbms_output.put_line( 'Request failed with status code ' || response_status );
    dbms_output.put_line( 'Response body: ' || response_body );
  end if;
  

  -- Example: execute POST http request. 
  -- Data will be sent with application/json Content-Type header (default configured mime type)
  -- POST https://host/api/v1/items/new
  myService.request( 
      method => 'POST'
    , url    => '/items/new'
    , status => response_status
    , body   => response_body 
    , data   => '{ "item": "5678" }'
  );

  -- Process response
  if response_status = 201 
  then
    dbms_output.put_line( 'Successfully created new item' );
    dbms_output.put_line( 'Response body: ' || response_body );
  else
    dbms_output.put_line( 'Request failed with status code ' || response_status );
    dbms_output.put_line( 'Response body: ' || response_body );
  end if;


  -- Example: execute POST http request.
  -- Data will be sent with application/xml Content-Type header
  -- POST https://host/api/v1/items/new
  myService.request( 
      method    => 'POST'
    , url       => '/items/new'
    , status    => response_status
    , body      => response_body 
    , data      => '<items><item>4321</item></items>'
    , mime_type => 'application/xml'
  );

  -- Process response
  if response_status = 201 
  then
    dbms_output.put_line( 'Successfully created new item' );
    dbms_output.put_line( 'Response body: ' || response_body );
  else
    dbms_output.put_line( 'Request failed with status code ' || response_status );
    dbms_output.put_line( 'Response body: ' || response_body );
  end if;


  -- Example: get response body if response status matches 2xx mask
  -- GET https://host/api/v1/info
  response_body := myService.fetch_response( '/info' );
  dbms_output.put_line( 'Response body: ' || response_body );


  -- Example: get response body if response status matches 2xx mask, otherwise return default message
  -- GET https://host/api/v1/info
  response_body := myService.fetch_response( '/info', alt => 'default message' );
  dbms_output.put_line( 'Response body: ' || response_body );


  -- Example: usage in cursors (not recommended, but possible)
  -- GET https://host/api/v1/stores/:id
  for rec in ( select st.id
                    , myService.fetch_response( url    => '/stores/' || st.id
                                              , method => 'GET'
                                              , status => '2xx'
                                              , alt    => 'not available' )
                      as response
                 from stores st
                where st.id between 1 and 10 )
  loop
    dbms_output.put_line( 'For store ' || rec.id || ' response is ' || rec.response );
  end loop;
end;
/
```

### SQL queries

Though it's possible to fetch http responses from sql queries, it's not the recommended way of using this tool due to possible perfomance issues, especially on large result sets. However, a query might look like this:

``` sql
with services as (
  select pl_request( base_url        => 'https://host/api/stores/v1'
                   , wallet_path     => 'file:/wallet_path'
                   , wallet_password => 'wallet_password'
                   , headers         => pl_requests_http_headers(
                         pl_requests_http_header( 'Accept', 'application/json' )
                       , pl_requests_http_header( 'X-Api-Key', 'service secret api key' )
                     ) )
         as stores
       , pl_request( base_url        => 'https://host/api/stock/v1'
                   , wallet_path     => 'file:/wallet_path'
                   , wallet_password => 'wallet_password'
                   , headers         => pl_requests_http_headers(
                         pl_requests_http_header( 'Accept', 'application/json' )
                       , pl_requests_http_header( 'X-Api-Key', 'service secret api key' )
                     ) )
         as stock
    from dual
)
select st.id
       -- GET https://host/api/stores/v1/:id
     , svc.stores.fetch_response( url => '/' || st.id
                                , alt => 'INFO_NOT_AVAILABLE' )
       as store_info
       -- GET https://host/api/stocks/v1/stores/:id?status=total
     , svc.stock.fetch_response( url => '/stores/' || st.id || '?status=total'
                               , alt => 'INFO_NOT_AVAILABLE' )
       as stock_total
       -- GET https://host/api/stocks/v1/stores/:id?status=available
     , svc.stock.fetch_response( url => '/stores/' || st.id || '?status=available'
                               , alt => 'INFO_NOT_AVAILABLE' )
       as stock_available
  from stores st
cross join services svc
```

### Requests Storage

Configured API service access instances can be stored in tables. Example:

``` sql
-------------------
-- Prerequisites --
-------------------

-- Create storage table
create table requests_storage (
    service_name varchar2(256) primary key
  , request      pl_request
) nested table request.headers
  store as requests_storage_headers
/

-- Store request instance settings in storage table
insert into requests_storage (
    service_name
  , request
) values (
    'external-locations-service'
  , pl_request(
        base_url        => 'https://host/api/locations/v1'
      , wallet_path     => 'file:/wallet_path'
      , wallet_password => 'wallet_password'
      , headers         => pl_requests_http_headers(
            pl_requests_http_header( 'Accept', 'application/json' )
          , pl_requests_http_header( 'X-Api-Key', 'service secret api key' )
        )
    )
);

-- Store request instance settings in storage table as PL_REQUEST_JSON 
-- Requires PLJSON and PL_REQUEST_JSON to be installed
insert into requests_storage (
    service_name
  , request
) values (
    'json:external-locations-service'
  , pl_request_json(
        base_url        => 'https://host/api/locations/v1'
      , wallet_path     => 'file:/wallet_path'
      , wallet_password => 'wallet_password'
      , headers         => pl_requests_http_headers(
            pl_requests_http_header( 'Accept', 'application/json' )
          , pl_requests_http_header( 'X-Api-Key', 'service secret api key' )
        )
    )
);

commit
/


----------------------------------
-- PL/SQL blocks usage examples --
----------------------------------

-- PL_REQUEST
declare
  api_service pl_request;
  l_status    number;
  l_body      varchar2(4000);
begin
  select st.request
    into api_service
    from requests_storage st
   where st.service_name = 'external-locations-service';

  api_service.request(
      method => 'GET'
    , url    => '/stores/3'
    , status => l_status
    , body   => l_body
  );
  
  dbms_output.put_line( 'Response status: ' || l_status );
  dbms_output.put_line( 'Response body:' || chr(13) || l_body );
end;
/

-- PL_REQUEST_JSON
declare
  api_service pl_request_json;
  l_status    number;
  l_body      pljson;
begin
  select treat( st.request as pl_request_json )
    into api_service
    from requests_storage st
   where st.service_name = 'json:external-locations-service';

  api_service.request(
      method => 'GET'
    , url    => '/stores/3'
    , status => l_status
    , body   => l_body
  );
  
  dbms_output.put_line( 'Response status: ' || l_status );
  dbms_output.put_line( 'Response body:' );

  if l_body is not null 
  then
    l_body.print();
  end if;
end;
/


------------------------
-- SQL query examples --
------------------------

-- Base example
select st.*
     , st.request.fetch_response( '/stores/3' ) 
       as "STORE_3"    -- VARCHAR2(4000)
     , st.request.fetch_response( '/warehouses/777' ) 
       as "WH_777"     -- VARCHAR2(4000)
     , st.request.fetch_response( '/countries' ) 
       as "COUNTRIES"  -- VARCHAR2(4000)
  from xxlm_requests st
 where st.service_name = 'external-locations-service'
/

-- PL_REQUEST_JSON example
select st.*
     , st.request.fetch_json( '/stores/3' ) 
       as "STORE_3"           -- PLJSON
     , st.request.fetch_json( '/warehouses/777' ) 
       as "WH_777"            -- PLJSON
     , st.request.fetch_json( '/countries' ) 
       as "COUNTRIES"         -- PLJSON
     , st.request.fetch_response( '/countries' ) 
       as "COUNTRIES_STRING"  -- VARCHAR2(4000)
  from ( select st.service_name
              , treat( st.request as pl_request_json )
                as request
           from xxlm_requests st
          where st.service_name = 'json:external-locations-service' ) st
/
```

## Installation

Base functionality can be installed with either `sqlplus` or `sqlcl`. 
If objects must be installed on schema other than login user - configure `CURRENT_SCHEMA` under opened session before running installation scripts. Note that login user must have privileges to create packages and types on target schema.

``` sql
-- sqlplus $USERNAME/$PASSWORD@$CONNECTION

-- [OPTIONAL]: set target installation schema if it differs from login user.
-- Note that login user must have necessary privileges for working with target schema
alter session set current_schema=TARGET_SCHEMA_NAME;


-- Install base functionality
-- Requires privileges to create packages and types
@install.sql


-- [OPTIONAL]: Install extension for PLJSON.
-- Requires PLJSON to be installed and privileges to create types
@scripts/install_pl_request_json.sql


-- [OPTIONAL]: Create public synonyms for PL_REQUESTS objects and known extensions.
-- Requires privileges to create public synonyms
@scripts/create_synonyms.sql
```

Uninstall process is similar to installation:

``` sql
-- sqlplus $USERNAME/$PASSWORD@$CONNECTION

-- [OPTIONAL]: set target installation schema if it differs from login user.
-- Note that login user must have necessary privileges for working with target schema
alter session set current_schema=TARGET_SCHEMA_NAME;


-- [OPTIONAL]: Drop public synonyms for PL_REQUESTS objects and known extensions.
-- Should be executed only if @scripts/create_synonyms.sql was run during installation.
-- Requires privileges to drop public synonyms
@scripts/drop_synonyms.sql


-- Uninstall base functionality and known extensions.
-- Requires privileges to drop packages and types
@uninstall.sql
```

