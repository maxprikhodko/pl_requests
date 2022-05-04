create or replace
package pl_requests_helpers
is
  gc_PROTOCOL constant number := 2;
  gc_HOST     constant number := 3;
  gc_PATH     constant number := 4;
  gc_QUERY    constant number := 5;

  /**
   * Resolves and partly normalizes url path
   * @param url url path part
   * @param base_url (optional) base url
   * @return full url string
   */
  function resolve_url( path     in varchar2
                      , base_url in varchar2
                                    default null )
                        return varchar2;

  /**
   * Gets url part
   * @param url full url path
   * @param token part to retrieve from path (host, protocol, path, query)
   * @return url part value or null if not found
   */
  function parse_url( url   in varchar2
                    , token in varchar2 )
                      return varchar2;
  
  
  /**
   * Sets header value in storage
   * @param name header name
   * @param val header value
   * @param headers_storage target headers collection
   * @param append (default false) appends header value to existing instance in collection
   */
  procedure set_header( name            in            varchar2
                      , val             in            varchar2
                      , headers_storage in out nocopy pl_request_headers
                      , append          in            boolean
                                                      default false );
  
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