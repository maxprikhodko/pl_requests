create or replace
package pl_requests_helpers
is
  /**
   * <p>Base pl_requests utilities.</p>
   * @headcom
   */
  
  /** URL protocol regexp group index */
  gc_PROTOCOL constant number := 2;
  /** URL host regexp group index */
  gc_HOST     constant number := 3;
  /** URL path regexp group index */
  gc_PATH     constant number := 4;
  /** URL query regexp group index */
  gc_QUERY    constant number := 5;

  /**
   * Returns matching MIME type
   * @return matched mime type or initial value
   */
  function MIME( name in varchar2 )
                 return varchar2;

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
                      , headers_storage in out nocopy pl_requests_http_headers
                      , append          in            boolean
                                                      default false );
  
  /**
   * Returns header value from collection
   * @param name header name
   * @param headers_storage source headers collection
   * @return header value or null if not found or uninitialized
   */
  function get_header( name            in varchar2
                     , headers_storage in pl_requests_http_headers )
                       return varchar2;

  /**
   * "Merges" two request headers storage into one.
   * Header values present both in left and right will be overriden by value from right.
   * @param l left storage
   * @param r (default null) right storage
   * @return merged storage
   */
  function merge_headers( l in pl_requests_http_headers
                        , r in pl_requests_http_headers
                               default null )
                          return pl_requests_http_headers;
end pl_requests_helpers;
/