# PL_REQUESTS

A simple wrapper around UTL_HTTP for performing HTTP requests from database. Something like nodejs `axios` or python `requests`, but for pl/sql.

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

