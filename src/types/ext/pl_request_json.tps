create or replace 
type pl_request_json under pl_request (
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
) not final
/