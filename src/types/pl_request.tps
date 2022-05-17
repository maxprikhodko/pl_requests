create or replace
type pl_request force is object
(
    /**
     * <p>Defines a HTTP-service based settings container for building HTTP requests in PLSQL code. 
     * Instance of this object is something like <code>axios.create()</code> in nodejs axios package.</p>
     * @headcom
     */
   
    /** Base url for all child requests */
    base_url        varchar2(2048)
    /** Wallet path (used for request context creation) */
  , wallet_path     varchar2(2048)
    /** Wallet password (used for request context creation) */
  , wallet_password varchar2(2048)
    /** HTTP headers set for every child request by default */
  , headers         pl_requests_http_headers
    /** HTTP headers set for every child request by default */
  , charset         varchar2(32)
    /** Default setting for forcing Transfer-Encoding: chunked by default */
  , chunked         varchar2(1 byte)
    /** Default mime type to be set for child requests data */
  , mime_type       varchar2(512)

    /**
     * Creates a configured http service access instance
     * @param base_url base url
     * @param wallet_path (default null) wallet path
     * @param wallet_password (default null) wallet password
     * @param charset (default null) charset to be used by all child requests by default
     * @param chunked (default null) force Transfer-Encoding: chunked by default
     * @param mime_type (default 'plain/text') default mime type to be set for requests data
     * @param headers (default null) headers to be sent with all child requests
     * @return pl_request instance (configured http service access instance)
     */
  , constructor function pl_request( base_url        varchar2
                                   , wallet_path     varchar2
                                                     default null
                                   , wallet_password varchar2
                                                     default null
                                   , charset         varchar2
                                                     default null
                                   , chunked         boolean
                                                     default false
                                   , mime_type       varchar2
                                                     default 'text/plain'
                                   , headers         pl_requests_http_headers
                                                     default null )
                                     return self as result
    /**
     * Returns global header for stored request
     * @param name header name
     * @return header value or null if not found or uninitialized
     */
  , member function get_header( name in varchar2 )
                                return varchar2
    /**
     * Sets global header for stored request
     * @param name header name
     * @param val header value
     */
  , member procedure set_header( name in varchar2
                               , val  in varchar2 )
    
    /**
     * Resolves provided url relative to specified base url
     * @param target target url
     * @return resolved url
     */
  , member function resolve( target varchar2
                                    default null )
                             return varchar2

    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param headers response headers output
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     * @param mime_type (default null) mime type to be specified in content-type header for request data
     * @param charset (default null) charset to be used for request and response bodies
     * @param chunked (default null) force Transfer-Encoding: chunked
     * @param req_headers (default null) additional http headers
     */
  , member procedure request( method      in            varchar2
                            , url         in            varchar2
                            , headers     in out nocopy pl_requests_http_headers
                            , status      in out nocopy number
                            , body        in out nocopy varchar2
                            , data        in            varchar2
                                                        default null
                            , mime_type   in            varchar2
                                                        default null
                            , charset     in            varchar2
                                                        default null
                            , chunked     in            boolean
                                                        default null
                            , req_headers in            pl_requests_http_headers
                                                        default null )
   
    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     * @param mime_type (default null) mime type to be specified in content-type header for request data
     * @param charset (default null) charset to be used for request and response bodies
     * @param chunked (default null) force Transfer-Encoding: chunked
     * @param req_headers (default null) additional http headers
     */
  , member procedure request( method      in            varchar2
                            , url         in            varchar2
                            , status      in out nocopy number
                            , body        in out nocopy varchar2
                            , data        in            varchar2
                                                        default null
                            , mime_type   in            varchar2
                                                        default null
                            , charset     in            varchar2
                                                        default null
                            , chunked     in            boolean
                                                        default null
                            , req_headers in            pl_requests_http_headers
                                                        default null )
   
    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param headers response headers output
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     * @param mime_type (default null) mime type to be specified in content-type header for request data
     * @param charset (default null) charset to be used for request and response bodies
     * @param chunked (default null) force Transfer-Encoding: chunked
     * @param req_headers (default null) additional http headers
     */
  , member procedure request( method      in            varchar2
                            , url         in            varchar2
                            , headers     in out nocopy pl_requests_http_headers
                            , status      in out nocopy number
                            , body        in out nocopy clob
                            , data        in            clob
                                                        default null
                            , mime_type   in            varchar2
                                                        default null
                            , charset     in            varchar2
                                                        default null
                            , chunked     in            boolean
                                                        default null
                            , req_headers in            pl_requests_http_headers
                                                        default null )
   
   
    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     * @param mime_type (default null) mime type to be specified in content-type header for request data
     * @param charset (default null) charset to be used for request and response bodies
     * @param chunked (default null) force Transfer-Encoding: chunked
     * @param req_headers (default null) additional http headers
     */
  , member procedure request( method      in            varchar2
                            , url         in            varchar2
                            , status      in out nocopy number
                            , body        in out nocopy clob
                            , data        in            clob
                                                        default null
                            , mime_type   in            varchar2
                                                        default null
                            , charset     in            varchar2
                                                        default null
                            , chunked     in            boolean
                                                        default null
                            , req_headers in            pl_requests_http_headers
                                                        default null )
   
   /**
    * Executes http request. Fetches response body if response status matches the expected.
    * @param body output response body clob
    * @param expected output flag indicating if response status code matches the expected status mask. Null is set on exceptions
    * @param url relative url
    * @param status (default '2xx') expected response status mask. If set to null, any response status code is valid
    * @param method (default 'GET') http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
    * @param data (default null) request data to send in body
    * @param mime_type (default null) mime type to be specified in content-type header for request data
    * @param charset (default null) charset to be used for request and response bodies
    * @param chunked (default null) 'T'=true, 'F'=false - force Transfer-Encoding: chunked
    * @param req_headers (default null) additional http headers
    */
  , member procedure fetch_clob( self        in            pl_request
                               , body        in out nocopy clob
                               , expected    in out nocopy boolean
                               , url         in            varchar2
                               , status      in            varchar2
                                                           default '2xx'
                               , method      in            varchar2
                                                           default 'GET'
                               , data        in            clob
                                                           default null
                               , mime_type   in            varchar2
                                                           default null
                               , charset     in            varchar2
                                                           default null
                               , chunked     in            varchar2
                                                           default null
                               , req_headers in            pl_requests_http_headers
                                                           default null )

   /**
    * Executes HTTP request and returns response body if response status matches the expected.
    * Response body must not exceed 4000 bytes.
    * Returns null if any exception occures.
    * @param url relative url
    * @param status (default '2xx') expected response status mask
    * @param method (default 'GET') http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
    * @param alt (default null) alternative message to be returned if response status does not match the expected
    * @param data (default null) request data to send in body
    * @param mime_type (default null) mime type to be specified in content-type header for request data
    * @param charset (default null) charset to be used for request and response bodies
    * @param chunked (default null) 'T'=true, 'F'=false - force Transfer-Encoding: chunked
    * @param req_headers (default null) additional http headers
    * @return response body string
    */
  , member function fetch_response( url         in varchar2
                                  , status      in varchar2
                                                   default '2xx'
                                  , method      in varchar2
                                                   default 'GET'
                                  , alt         in varchar2
                                                   default null
                                  , data        in varchar2
                                                   default null
                                  , mime_type   in varchar2
                                                   default null
                                  , charset     in varchar2
                                                   default null
                                  , chunked     in varchar2
                                                   default null 
                                  , req_headers in pl_requests_http_headers
                                                   default null )
                                    return varchar2
) not final
/
