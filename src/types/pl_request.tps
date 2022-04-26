create or replace
type pl_request is object
(
    base_url        varchar2(2048)
  , wallet_path     varchar2(2048)
  , wallet_password varchar2(2048)
  , headers         pl_request_headers

  , constructor function pl_request( base_url        varchar2
                                   , wallet_path     varchar2
                                                     default null
                                   , wallet_password varchar2
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
)
/
