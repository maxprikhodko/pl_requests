create or replace
package pl_requests
is
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
