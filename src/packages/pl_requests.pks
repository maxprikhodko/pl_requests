create or replace
package pl_requests
is
  gc_DEFAULT_CHARSET constant varchar2(32) := 'UTF-8';

  /**
   * Execute http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param req_headers (optional) request headers
   * @param res_status response status storage
   * @param res_body response body storage
   * @param ctx (optional) request context key
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , req_headers in            pl_request_headers
                                               default null
                   , res_status  in out nocopy number
                   , res_body    in out nocopy varchar2
                   , ctx         in            utl_http.request_context_key
                                               default null );

  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_headers output response headers storage
   * @param res_status output response status
   * @param res_body output response body clob
   * @param ctx (default null) request context key
   * @param req_headers (default null) request headers to be set
   * @param req_data (default null) request data clob to be sent in body
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_headers in out nocopy pl_request_headers
                   , res_status  in out nocopy number
                   , res_body    in out nocopy clob
                   , ctx         in            utl_http.request_context_key
                                               default null
                   , req_headers in            pl_request_headers
                                               default null
                   , req_data    in            clob
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET );
  
  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_headers output response headers storage
   * @param res_status output response status
   * @param res_body output response body text
   * @param ctx (default null) request context key
   * @param req_headers (default null) request headers to be set
   * @param req_data (default null) request data text to be sent in body
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_headers in out nocopy pl_request_headers
                   , res_status  in out nocopy number
                   , res_body    in out nocopy varchar2
                   , ctx         in            utl_http.request_context_key
                                               default null
                   , req_headers in            pl_request_headers
                                               default null
                   , req_data    in            varchar2
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET );

  /**
   * Collects all response headers from response to headers collection
   * @param res response object
   * @param headers destination headers collection
   */
  procedure get_headers( res     in out nocopy utl_http.resp
                       , headers in out nocopy pl_request_headers );
  
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
   */
  procedure set_headers( req     in out nocopy utl_http.req
                       , headers in            pl_request_headers );

  /**
   * Sets request body from string
   * @param req request object
   * @param body string body to set
   */
  procedure set_body( req  in out nocopy utl_http.req
                    , body in            varchar2 );
  
  /**
   * Sets request body from blob
   * @param req request object
   * @param body blob body to set
   */
  procedure set_body( req  in out nocopy utl_http.req
                    , body in            blob );
end pl_requests;
/
