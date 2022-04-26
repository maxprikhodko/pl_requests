create or replace
package pl_requests_helpers
is
  /**
   * Sets header value in storage
   * @param name header name
   * @param val header value
   * @param headers_storage target headers collection
   */
  procedure set_header( name            in            varchar2
                      , val             in            varchar2
                      , headers_storage in out nocopy pl_request_headers );
  
  /**
   * Returns header value from collection
   * @param name header name
   * @param headers_storage source headers collection
   * @return header value or null if not found or uninitialized
   */
  function get_header( name            in varchar2
                     , headers_storage in pl_request_headers )
                       return varchar2;
end pl_requests_helpers;
/