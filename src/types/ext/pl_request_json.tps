create or replace 
type pl_request_json under pl_request (
    /**
     * <p>Defines an extension for pl_request instance which can work with
     * json data automatically. Depends on PLJSON objects and API.</p>
     * @headcom
     */


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
    constructor function pl_request_json( base_url        varchar2
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
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param headers response headers output
     * @param status response status output
     * @param body JSON response body output
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
                            , body        in out nocopy pljson
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
     * @param body JSON response body output
     * @param data (default null) request data to send in body
     * @param mime_type (default null) mime type to be specified in content-type header for request data
     * @param charset (default null) charset to be used for request and response bodies
     * @param chunked (default null) force Transfer-Encoding: chunked
     * @param req_headers (default null) additional http headers
     */
  , member procedure request( method      in            varchar2
                            , url         in            varchar2
                            , status      in out nocopy number
                            , body        in out nocopy pljson
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
     * @param headers response headers output
     * @param status response status output
     * @param body JSON response body output
     * @param data (default null) JSON request data to send in body
     * @param charset (default null) charset to be used for request and response bodies
     * @param chunked (default null) force Transfer-Encoding: chunked
     * @param req_headers (default null) additional http headers
     */
  , member procedure request( method      in            varchar2
                            , url         in            varchar2
                            , headers     in out nocopy pl_requests_http_headers
                            , status      in out nocopy number
                            , body        in out nocopy pljson
                            , data        in            pljson
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
     * @param body JSON response body output
     * @param data (default null) JSON request data to send in body
     * @param charset (default null) charset to be used for request and response bodies
     * @param chunked (default null) force Transfer-Encoding: chunked
     * @param req_headers (default null) additional http headers
     */
  , member procedure request( method      in            varchar2
                            , url         in            varchar2
                            , status      in out nocopy number
                            , body        in out nocopy pljson
                            , data        in            pljson
                            , charset     in            varchar2
                                                        default null
                            , chunked     in            boolean
                                                        default null
                            , req_headers in            pl_requests_http_headers
                                                        default null )
  
   /**
    * Executes HTTP request and returns response JSON body if response status matches the expected.
    * Returns null if any exception occures.
    * @param url relative url
    * @param status (default '2xx') expected response status mask
    * @param method (default 'GET') http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
    * @param alt (default null) alternative JSON body to be returned if response status does not match the expected
    * @param data (default null) request data clob to send in body
    * @param mime_type (default null) mime type to be specified in content-type header for request data
    * @param charset (default null) charset to be used for request and response bodies
    * @param chunked (default null) 'T'=true, 'F'=false - force Transfer-Encoding: chunked
    * @param req_headers (default null) additional http headers
    * @return response body JSON
    */
  , member function fetch_json( url         in varchar2
                              , status      in varchar2
                                               default '2xx'
                              , method      in varchar2
                                               default 'GET'
                              , alt         in pljson
                                               default null
                              , data        in clob
                                               default null
                              , mime_type   in varchar2
                                               default null
                              , charset     in varchar2
                                               default null
                              , chunked     in varchar2
                                               default null
                              , req_headers in pl_requests_http_headers
                                               default null )
                                return pljson

   /**
    * Executes HTTP request and returns response JSON body if response status matches the expected.
    * Returns null if any exception occures.
    * @param url relative url
    * @param status (default '2xx') expected response status mask
    * @param method (default 'GET') http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
    * @param alt (default null) alternative JSON body to be returned if response status does not match the expected
    * @param data (default null) request data JSON to send in body
    * @param charset (default null) charset to be used for request and response bodies
    * @param chunked (default null) 'T'=true, 'F'=false - force Transfer-Encoding: chunked
    * @param req_headers (default null) additional http headers
    * @return response body JSON
    */
  , member function fetch_json( url         in varchar2
                              , status      in varchar2
                                               default '2xx'
                              , method      in varchar2
                                               default 'GET'
                              , alt         in pljson
                                               default null
                              , data        in pljson
                              , charset     in varchar2
                                               default null
                              , chunked     in varchar2
                                               default null
                              , req_headers in pl_requests_http_headers
                                               default null )
                                return pljson
) not final
/