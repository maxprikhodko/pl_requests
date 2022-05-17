# Type PL_REQUEST_JSON

## Overview

This object extends base `PL_REQUEST` type with additional functionality for handling JSON data type in requests. Depends on `PLJSON` which must be installed before installing this extension of `PL_REQUESTS` toolset.

In brief, this type inherits `PL_REQUEST` with the following changes/additions:

- Adds more `request()` procedure overloads for handling request data and response bodies as `pljson` objects;
- Adds new `fetch_json()` functions for response body conditional receiving as `pljson` object.

Initial functionality of `PL_REQUEST` object is available from `PL_REQUEST_JSON` instance.

## Properties

Refer to [PL_REQUEST properties](./PL_REQUEST.md#Properties) documentation.

## Constructor

Refer to [PL_REQUEST constructor](./PL_REQUEST.md#Constructor) documentation.

## `request` member procedures

Refer to [PL_REQUEST request](./PL_REQUEST.md#request-member-procedures) documentation for inherited overloads.

### Syntax

``` sql
-- CLOB data overloads
pl_request_json.request( self        in out        pl_request_json
                       , method      in            varchar2
                       , url         in            varchar2
                       , headers     in out nocopy pl_requests_http_headers
                       , status      in out nocopy number
                       , body        in out nocopy pljson
                       , data        in            clob                     default null
                       , mime_type   in            varchar2                 default null
                       , charset     in            varchar2                 default null
                       , chunked     in            boolean                  default null
                       , req_headers in            pl_requests_http_headers default null );

pl_request_json.request( self        in out        pl_request_json
                       , method      in            varchar2
                       , url         in            varchar2
                       , status      in out nocopy number
                       , body        in out nocopy pljson
                       , data        in            clob                     default null
                       , mime_type   in            varchar2                 default null
                       , charset     in            varchar2                 default null
                       , chunked     in            boolean                  default null
                       , req_headers in            pl_requests_http_headers default null );

-- PLJSON data overloads
pl_request_json.request( self        in out        pl_request_json
                       , method      in            varchar2
                       , url         in            varchar2
                       , headers     in out nocopy pl_requests_http_headers
                       , status      in out nocopy number
                       , body        in out nocopy pljson
                       , data        in            pljson
                       , charset     in            varchar2                 default null
                       , chunked     in            boolean                  default null
                       , req_headers in            pl_requests_http_headers default null );

pl_request_json.request( self        in out        pl_request_json
                       , method      in            varchar2
                       , url         in            varchar2
                       , status      in out nocopy number
                       , body        in out nocopy pljson
                       , data        in            pljson
                       , charset     in            varchar2                 default null
                       , chunked     in            boolean                  default null
                       , req_headers in            pl_requests_http_headers default null );
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|method|`varchar2`|IN||Yes|HTTP method (`'GET'`, `'POST'`, `'PUT'`, `'PATCH'`, `'DELETE'`, `'OPTIONS'`). Case-insensitive.|
|url|`varchar2`|IN||Yes|URL path relative to `self.base_url`|
|headers|`pl_requests_http_headers`|IN OUT||No*|Received response headers output.|
|status|`number`|IN OUT||Yes|Response status code output|
|body|`pljson`|IN OUT||Yes|Received response body JSON object output.|
|data|`clob` or `pljson`|IN|`null`|No*|Request data to send in body. When specified of `pljson` type, `application/json` mime type is set.|
|mime_type|`varchar2`|IN|`null`|No*|Mime type to be specified in "Content-Type" header for request data. Defaults to `self.mime_type` if `null` parameter value specified. **This parameter is not available when request data value is of** `pljson` **type**.|
|charset|`varchar2`|IN|`null`|No|Charset to be used for request and response bodies. Final value is resolved with expression `coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )`.|
|chunked|`boolean`|IN|`null`|No|Force "Transfer-Encoding: chunked". Setting value is resolved with expression `coalesce( chunked, self.chunked = 'T', false )`.|
|req_headers|`pl_requests_http_headers`|IN|`null`|No|Additional request headers. If header name is present in `req_headers` and `self.headers` - header value will be overrided for this request only or header will be removed if its value in `req_headers` is `null`.|

### Description

Resolves `url` relative to current `self.base_url` and executes HTTP request. Request is sent with all previously configured data in `self` merged with specified callback parameters (request data, headers, settings overrides, etc.). Returns response status, body and headers (optionally) into matching OUT variables. If `body` output parameter is specified of `pljson` type, response body is parsed to a `pljson` object.

`Content-Type`, `Content-Length` and `Transfer-Encoding` request headers are handled automatically.

## `fetch_json` member functions

### Syntax

``` sql
pl_request_json.fetch_json( self        in pl_request_json
                          , url         in varchar2
                          , status      in varchar2            default '2xx'
                          , method      in varchar2            default 'GET'
                          , alt         in pljson              default null
                          , data        in clob                default null
                          , mime_type   in varchar2            default null
                          , charset     in varchar2            default null
                          , chunked     in varchar2            default null
                          , req_headers in pl_requests_headers default null )
                            return pljson;

pl_request_json.fetch_json( self        in pl_request_json
                          , url         in varchar2
                          , status      in varchar2            default '2xx'
                          , method      in varchar2            default 'GET'
                          , alt         in pljson              default null
                          , data        in pljson
                          , charset     in varchar2            default null
                          , chunked     in varchar2            default null
                          , req_headers in pl_requests_headers default null )
                            return pljson;
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|url|`varchar2`|IN||Yes|URL path relative to `self.base_url`|
|status|`varchar2`|IN|`'2xx'`|No|Expected response status mask. Must match `^[1-5][0-9X]{2}$i` regular expression. If set to `null`, any response status code is valid.|
|method|`varchar2`|IN|`'GET'`|No|HTTP method (`'GET'`, `'POST'`, `'PUT'`, `'PATCH'`, `'DELETE'`, `'OPTIONS'`). Case-insensitive.|
|alt|`pljson`|IN|`null`|No|JSON object value to be returned if actual response status does not match expected status mask.|
|data|`clob` or `pljson`|IN|`null`|No*|Request data to send in body. When specified of `pljson` type, `application/json` mime type is set.|
|mime_type|`varchar2`|IN|`null`|No*|Mime type to be specified in "Content-Type" header for request data. Defaults to `self.mime_type` if `null` parameter value specified. **This parameter is not available when request data value is of** `pljson` **type**.|
|charset|`varchar2`|IN|`null`|No|Charset to be used for request and response bodies. Final value is resolved with expression `coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )`.|
|chunked|`varchar2`|IN|`null`|No|Force "Transfer-Encoding: chunked". Setting value is resolved with expression like `coalesce( chunked = 'T', self.chunked = 'T', false )`. Valid values are: `null`, `'T'`, `'F'`.|
|req_headers|`pl_requests_http_headers`|IN|`null`|No|Additional request headers. If header name is present in `req_headers` and `self.headers` - header value will be overrided for this request only or header will be removed if its value in `req_headers` is `null`.|

### Description

Resolves `url` relative to current `self.base_url` and executes HTTP request. Request is sent with all previously configured data in `self` merged with specified callback parameters (request data, headers, settings overrides, etc.). If response status matches the `status` mask, returns response body parsed as `pljson` object, otherwise returns `alt` value. Returns `null` on exceptions.

`Content-Type`, `Content-Length` and `Transfer-Encoding` request headers are handled automatically.