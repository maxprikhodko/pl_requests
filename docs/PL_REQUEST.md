# Type PL_REQUEST

## Overview

This object is a basic container of settings and entry point for requests to external HTTP API service. Core concept is to define necessary settings and prerequisites once (and to store them, for example, in a package global variable) with this object type and to use its instance for further communication with external server.

In brief, current implementation exposes following APIs and methods:

- URL path relative to baseURL resolution: `resolve()` function;
- Request instance default headers control: `set_header()` procedure, `get_header()` function;
- HTTP requests execution: `request()` and `fetch_clob()` procedures, `fetch_response()` function.

## Properties

All object properties should be treated as `PROTECTED` and should not be modified directly.

|Name|Type|Description|
|---|---|---|
|base_url|`varchar2(2048)`|URL which will be appended to the start of url paths in all child requests.|
|wallet_path|`varchar2(2048)`|Oracle wallet path.|
|wallet_password|`varchar2(2048)`|Oracle wallet password.|
|headers|`pl_requests_http_headers`|Storage for headers which will be sent with all child requests by default.|
|charset|`varchar2(32)`|Setting to override default charset to be used in processing request\/response bodies.|
|chunked|`varchar2(1 byte)`|Force "Transfer-Encoding: chunked" for all child requests. Valid values are: `null`, `'T'`, `'F'`.|
|mime_type|`varchar2(512)`|Default mime type to be set in "Content-Type" header for request data.|

## Constructor

### Syntax

```
pl_request( base_url        varchar2
          , wallet_path     varchar2                 default null
          , wallet_password varchar2                 default null
          , charset         varchar2                 default null
          , chunked         boolean                  default false
          , mime_type       varchar2                 default 'text/plain'
          , headers         pl_requests_http_headers default null )
            return self as result;
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|base_url|`varchar2`|IN||Yes|URL which will be appended to the start of url paths in all child requests.|
|wallet_path|`varchar2`|IN|`null`|No|Oracle wallet path. If specified - each request will create request context and destroy it after request end.|
|wallet_password|`varchar2`|IN|`null`|No|Oracle wallet password. If specified with `wallet_path` - each request will create request context and destroy it after request end.|
|charset|`varchar2`|IN|`null`|No|Setting to override default charset to be used in processing request\/response bodies|
|chunked|`boolean`|IN|`false`|No|Force "Transfer-Encoding: chunked" for all child requests.|
|mime_type|`varchar2`|IN|`'text/plain'`|No|Default mime type to be set for requests data.|
|headers|`pl_requests_http_headers`|IN|`null`|No|Headers which will be sent with all child requests by default.|

## `resolve` member function

### Syntax

``` sql
pl_request.resolve( self   in pl_request
                  , target in varchar2 )
                    return varchar2;
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|target|`varchar2`|IN||Yes|URL path relative to `self.base_url`|

### Description

Resolves provided url relative to current base url.

## `set_header` member procedure

### Syntax

``` sql
pl_request.set_header( self in out pl_request
                     , name in     varchar2
                     , val  in     varchar2 );
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|name|`varchar2`|IN||Yes|HTTP header name.|
|val|`varchar2`|IN||Yes|HTTP header value.|

### Description

Sets default request header value. Overwrites with new value if header already exists.

## `get_header` member function

### Syntax

``` sql
pl_request.get_header( self in pl_request
                     , name in varchar2 )
                       return varchar2;
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|name|`varchar2`|IN||Yes|URL path relative to `self.base_url`|

### Description

Returns request header value from `self.headers` storage or null if not exists.

## `request` member procedures

### Syntax

``` sql
-- VARCHAR2 body/data overloads
pl_request.request( self        in out        pl_request
                  , method      in            varchar2
                  , url         in            varchar2
                  , headers     in out nocopy pl_requests_http_headers
                  , status      in out nocopy number
                  , body        in out nocopy varchar2
                  , data        in            varchar2                 default null
                  , mime_type   in            varchar2                 default null
                  , charset     in            varchar2                 default null
                  , chunked     in            boolean                  default null
                  , req_headers in            pl_requests_http_headers default null );

pl_request.request( self        in out        pl_request
                  , method      in            varchar2
                  , url         in            varchar2
                  , status      in out nocopy number
                  , body        in out nocopy varchar2
                  , data        in            varchar2                 default null
                  , mime_type   in            varchar2                 default null
                  , charset     in            varchar2                 default null
                  , chunked     in            boolean                  default null
                  , req_headers in            pl_requests_http_headers default null );

-- CLOB body/data overloads
pl_request.request( self        in out        pl_request
                  , method      in            varchar2
                  , url         in            varchar2
                  , headers     in out nocopy pl_requests_http_headers
                  , status      in out nocopy number
                  , body        in out nocopy clob
                  , data        in            clob                     default null
                  , mime_type   in            varchar2                 default null
                  , charset     in            varchar2                 default null
                  , chunked     in            boolean                  default null
                  , req_headers in            pl_requests_http_headers default null );

pl_request.request( self        in out        pl_request
                  , method      in            varchar2
                  , url         in            varchar2
                  , status      in out nocopy number
                  , body        in out nocopy clob
                  , data        in            clob                     default null
                  , mime_type   in            varchar2                 default null
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
|body|`varchar2` or `clob`|IN OUT||Yes|Received response body output. Specified clob buffer must be allocated before procedure invocation.|
|data|`varchar2` or `clob`|IN|`null`|No|Request data to send in body.|
|mime_type|`varchar2`|IN|`null`|No|Mime type to be specified in "Content-Type" header for request data. Defaults to `self.mime_type` if `null` parameter value specified.|
|charset|`varchar2`|IN|`null`|No|Charset to be used for request and response bodies. Final value is resolved with expression `coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )`.|
|chunked|`boolean`|IN|`null`|No|Force "Transfer-Encoding: chunked". Setting value is resolved with expression `coalesce( chunked, self.chunked = 'T', false )`.|
|req_headers|`pl_requests_http_headers`|IN|`null`|No|Additional request headers. If header name is present in `req_headers` and `self.headers` - header value will be overrided for this request only or header will be removed if its value in `req_headers` is `null`.|

### Description

Resolves `url` relative to current `self.base_url` and executes HTTP request. Request is sent with all previously configured data in `self` merged with specified callback parameters (request data, headers, settings overrides, etc.). Returns response status, body and headers (optionally) into matching OUT variables.

`Content-Type`, `Content-Length` and `Transfer-Encoding` request headers are handled automatically.

## `fetch_clob` member procedure

### Syntax

``` sql
pl_request.fetch_clob( self        in            pl_request
                     , body        in out nocopy clob
                     , expected    in out nocopy boolean
                     , url         in            varchar2
                     , status      in            varchar2            default '2xx'
                     , method      in            varchar2            default 'GET'
                     , data        in            clob                default null
                     , mime_type   in            varchar2            default null
                     , charset     in            varchar2            default null
                     , chunked     in            varchar2            default null
                     , req_headers in            pl_requests_headers default null );
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|body|`clob`|IN OUT||Yes|Received response body output. Specified clob buffer must be allocated before procedure invocation.|
|expected|`boolean`|IN OUT||Yes|Flag indicating if response status code matches the expected status mask. `Null` is set on exceptions|
|url|`varchar2`|IN||Yes|URL path relative to `self.base_url`|
|status|`varchar2`|IN|`'2xx'`|No|Expected response status mask. Must match `^[1-5][0-9X]{2}$i` regular expression. If set to `null`, any response status code is valid.|
|method|`varchar2`|IN|`'GET'`|No|HTTP method (`'GET'`, `'POST'`, `'PUT'`, `'PATCH'`, `'DELETE'`, `'OPTIONS'`). Case-insensitive.|
|data|`clob`|IN|`null`|No|Request data to send in body.|
|mime_type|`varchar2`|IN|`null`|No|Mime type to be specified in "Content-Type" header for request data. Defaults to `self.mime_type` if `null` parameter value specified.|
|charset|`varchar2`|IN|`null`|No|Charset to be used for request and response bodies. Final value is resolved with expression `coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )`.|
|chunked|`varchar2`|IN|`null`|No|Force "Transfer-Encoding: chunked". Setting value is resolved with expression like `coalesce( chunked = 'T', self.chunked = 'T', false )`. Valid values are: `null`, `'T'`, `'F'`.|
|req_headers|`pl_requests_http_headers`|IN|`null`|No|Additional request headers. If header name is present in `req_headers` and `self.headers` - header value will be overrided for this request only or header will be removed if its value in `req_headers` is `null`.|

### Description

Resolves `url` relative to current `self.base_url` and executes HTTP request. Request is sent with all previously configured data in `self` merged with specified callback parameters (request data, headers, settings overrides, etc.). If response status matches the `status` mask, reads response body into `body` clob buffer. Flag `expected` indicates if response body was read.

`Content-Type`, `Content-Length` and `Transfer-Encoding` request headers are handled automatically.

## `fetch_response` member function

### Syntax

``` sql
pl_request.fetch_response( self        in pl_request
                         , url         in varchar2
                         , status      in varchar2            default '2xx'
                         , method      in varchar2            default 'GET'
                         , alt         in varchar2            default null
                         , data        in varchar2            default null
                         , mime_type   in varchar2            default null
                         , charset     in varchar2            default null
                         , chunked     in varchar2            default null
                         , req_headers in pl_requests_headers default null )
                           return varchar2;
```

### Parameters

|Name|Type|Direction|Default Value|Required|Description|
|---|---|---|---|---|---|
|url|`varchar2`|IN||Yes|URL path relative to `self.base_url`|
|status|`varchar2`|IN|`'2xx'`|No|Expected response status mask. Must match `^[1-5][0-9X]{2}$i` regular expression. If set to `null`, any response status code is valid.|
|method|`varchar2`|IN|`'GET'`|No|HTTP method (`'GET'`, `'POST'`, `'PUT'`, `'PATCH'`, `'DELETE'`, `'OPTIONS'`). Case-insensitive.|
|alt|`varchar2`|IN|`null`|No|String to be returned if actual response status does not match expected status mask.|
|data|`varchar2`|IN|`null`|No|Request data to send in body.|
|mime_type|`varchar2`|IN|`null`|No|Mime type to be specified in "Content-Type" header for request data. Defaults to `self.mime_type` if `null` parameter value specified.|
|charset|`varchar2`|IN|`null`|No|Charset to be used for request and response bodies. Final value is resolved with expression `coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )`.|
|chunked|`varchar2`|IN|`null`|No|Force "Transfer-Encoding: chunked". Setting value is resolved with expression like `coalesce( chunked = 'T', self.chunked = 'T', false )`. Valid values are: `null`, `'T'`, `'F'`.|
|req_headers|`pl_requests_http_headers`|IN|`null`|No|Additional request headers. If header name is present in `req_headers` and `self.headers` - header value will be overrided for this request only or header will be removed if its value in `req_headers` is `null`.|

### Description

Resolves `url` relative to current `self.base_url` and executes HTTP request. Request is sent with all previously configured data in `self` merged with specified callback parameters (request data, headers, settings overrides, etc.). If response status matches the `status` mask, returns response body string, otherwise returns `alt` value. Return value is trimmed to 4000 bytes. Returns `null` on exceptions.

`Content-Type`, `Content-Length` and `Transfer-Encoding` request headers are handled automatically.
