create or replace
package pl_requests
is
  gc_DEFAULT_CHARSET constant varchar2(32) := 'UTF-8';
  gc_CHUNK_MAX_BYTES constant number       := 32767;
  gc_CHUNK_SIZE      constant number       := 32767;

  /**
   * Get default charset
   * @return default charset
   */
  function DEFAULT_CHARSET return varchar2;

  /**
   * Fetch response object from url. Fetched response MUST be closed manually.
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param opened output flag indicating if response is currently opened
   * @param headers (default null) request headers to be set
   * @param data (default null) request data clob to be sent in body
   * @param charset (default 'UTF-8') charset to be used for request body
   * @param chunked (default false) force Transfer-Encoding: chunked
   * @param mime_type (default 'text/plain') mime type to be specified in content-type header for request data
   * @param ctx (default null) request context key
   * @return utl_http.resp response object
   */
  function fetch_url( method    in            varchar2
                    , url       in            varchar2
                    , opened    in out nocopy boolean
                    , headers   in            pl_requests_http_headers
                                              default null
                    , data      in            clob
                                              default null
                    , charset   in            varchar2
                                              default gc_DEFAULT_CHARSET
                    , chunked   in            boolean
                                              default false
                    , mime_type in            varchar2
                                              default null
                    , ctx       in            utl_http.request_context_key
                                              default null )
                      return utl_http.resp;

  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_headers output response headers storage
   * @param res_status output response status
   * @param res_body output response body clob
   * @param req_data (default null) request data clob to be sent in body
   * @param req_headers (default null) request headers to be set
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   * @param chunked (default false) force Transfer-Encoding: chunked
   * @param mime_type (default 'text/plain') mime type to be specified in content-type header for request data
   * @param ctx (default null) request context key
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_headers in out nocopy pl_requests_http_headers
                   , res_status  in out nocopy number
                   , res_body    in out nocopy clob
                   , req_data    in            clob
                                               default null
                   , req_headers in            pl_requests_http_headers
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET
                   , chunked     in            boolean
                                               default false
                   , mime_type   in            varchar2
                                               default 'text/plain'
                   , ctx         in            utl_http.request_context_key
                                               default null );
  
  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_status output response status
   * @param res_body output response body clob
   * @param req_data (default null) request data clob to be sent in body
   * @param req_headers (default null) request headers to be set
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   * @param chunked (default false) force Transfer-Encoding: chunked
   * @param mime_type (default 'text/plain') mime type to be specified in content-type header for request data
   * @param ctx (default null) request context key
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_status  in out nocopy number
                   , res_body    in out nocopy clob
                   , req_data    in            clob
                                               default null
                   , req_headers in            pl_requests_http_headers
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET
                   , chunked     in            boolean
                                               default false
                   , mime_type   in            varchar2
                                               default 'text/plain'
                   , ctx         in            utl_http.request_context_key
                                               default null );
  
  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_headers output response headers storage
   * @param res_status output response status
   * @param res_body output response body text
   * @param req_data (default null) request data text to be sent in body
   * @param req_headers (default null) request headers to be set
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   * @param chunked (default false) force Transfer-Encoding: chunked
   * @param mime_type (default 'text/plain') mime type to be specified in content-type header for request data
   * @param ctx (default null) request context key
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_headers in out nocopy pl_requests_http_headers
                   , res_status  in out nocopy number
                   , res_body    in out nocopy varchar2
                   , req_data    in            varchar2
                                               default null
                   , req_headers in            pl_requests_http_headers
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET
                   , chunked     in            boolean
                                               default false
                   , mime_type   in            varchar2
                                               default 'text/plain'
                   , ctx         in            utl_http.request_context_key
                                               default null );
  
  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_status output response status
   * @param res_body output response body text
   * @param req_data (default null) request data text to be sent in body
   * @param req_headers (default null) request headers to be set
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   * @param chunked (default false) force Transfer-Encoding: chunked
   * @param mime_type (default 'text/plain') mime type to be specified in content-type header for request data
   * @param ctx (default null) request context key
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_status  in out nocopy number
                   , res_body    in out nocopy varchar2
                   , req_data    in            varchar2
                                               default null
                   , req_headers in            pl_requests_http_headers
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET
                   , chunked     in            boolean
                                               default false
                   , mime_type   in            varchar2
                                               default 'text/plain'
                   , ctx         in            utl_http.request_context_key
                                               default null );

  /**
   * Collects all response headers from response to headers collection
   * @param res response object
   * @param headers destination headers collection
   */
  procedure get_headers( res     in out nocopy utl_http.resp
                       , headers in out nocopy pl_requests_http_headers );
  
  /**
   * Reads response body into a clob variable
   * @param res response object
   * @param body output clob (must be allocated before call)
   * @param charset (default 'UTF-8') body charset
   */
  procedure get_body( res     in out nocopy utl_http.resp
                    , body    in out nocopy clob
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET );

  /**
   * Reads response body as text into string variable
   * @param res response object
   * @param body output buffer 
   * @param charset (default 'UTF-8') body charset
   */
  procedure get_body( res     in out nocopy utl_http.resp
                    , body    in out nocopy varchar2
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET );
  
  /**
   * Reads response body into blob
   * @param res response object
   * @param body output blob 
   */
  procedure get_body( res  in out nocopy utl_http.resp
                    , body in out nocopy blob );
  
  /**
   * Sets request headers
   * @param req request object
   * @param headers headers collection
   * @param ignore_list (default true) do not set headers from ignore list
   */
  procedure set_headers( req         in out nocopy utl_http.req
                       , headers     in            pl_requests_http_headers
                       , ignore_list in            boolean
                                                   default true );

  /**
   * Sets request body from string
   * @param req request object
   * @param body string body to set
   * @param charset (default 'UTF-8') request body charset to use
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure set_body( req     in out nocopy utl_http.req
                    , body    in            clob
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET
                    , chunked in            boolean
                                            default false );
  
  /**
   * Sets request body from string
   * @param req request object
   * @param body string body to set
   * @param charset (default 'UTF-8') request body charset to use
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure set_body( req     in out nocopy utl_http.req
                    , body    in            varchar2
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET
                    , chunked in            boolean
                                            default false );
  
  /**
   * Sets request body from blob
   * @param req request object
   * @param body blob body to set
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure set_body( req     in out nocopy utl_http.req
                    , body    in            blob
                    , chunked in            boolean
                                            default false );
end pl_requests;
/
