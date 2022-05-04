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

    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param headers response headers output
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     */
  , member procedure request( method  in            varchar2
                            , url     in            varchar2
                            , headers in out nocopy pl_request_headers
                            , status  in out nocopy number
                            , body    in out nocopy varchar2
                            , data    in            varchar2
                                                    default null )
   
    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     */
  , member procedure request( method in            varchar2
                            , url    in            varchar2
                            , status in out nocopy number
                            , body   in out nocopy varchar2
                            , data   in            varchar2
                                                   default null )
   
    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param headers response headers output
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     */
  , member procedure request( method  in            varchar2
                            , url     in            varchar2
                            , headers in out nocopy pl_request_headers
                            , status  in out nocopy number
                            , body    in out nocopy clob
                            , data    in            clob
                                                    default null )
   
   
    /**
     * Executes HTTP request
     * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
     * @param url relative url
     * @param status response status output
     * @param body response body output
     * @param data (default null) request data to send in body
     */
  , member procedure request( method in            varchar2
                            , url    in            varchar2
                            , status in out nocopy number
                            , body   in out nocopy clob
                            , data   in            clob
                                                   default null )
)
/
