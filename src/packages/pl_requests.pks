create or replace
package pl_requests
is
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
   * Collects all response headers from response to headers collection
   * @param res response object
   * @param headers destination headers collection
   */
  procedure get_headers( res     in out nocopy utl_http.resp
                       , headers in out nocopy pl_request_headers );

  /**
   * Reads response body as text into string variable
   * @param res response object
   * @param body destination 
   */
  procedure get_body( res  in out nocopy utl_http.resp
                    , body in out nocopy varchar2 );
  
  /**
   * Reads response body into blob
   * @param res response object
   * @param body destination 
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
