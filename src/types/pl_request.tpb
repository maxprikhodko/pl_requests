create or replace
type body pl_request
is
  constructor function pl_request( base_url        varchar2
                                 , wallet_path     varchar2
                                                   default null
                                 , wallet_password varchar2
                                                   default null
                                 , charset         varchar2
                                                   default null
                                 , chunked         boolean
                                                   default false
                                 , mime_type       varchar2
                                                   default 'text/plain' )
                                   return self as result
  is
  begin
    self.base_url := base_url;

    if wallet_path is not null and wallet_password is not null
    then
      self.wallet_path     := wallet_path;
      self.wallet_password := wallet_password;
    end if;
    
    self.charset   := nvl( charset, pl_requests.DEFAULT_CHARSET );
    self.chunked   := ( case when chunked then 'T' else 'F' end );
    self.mime_type := mime_type;
    return;
  end pl_request;

  /**
   * Returns global header from stored request
   * @param name header name
   * @return header value or null if not found or uninitialized
   */         
  member function get_header( name varchar2 )
                              return varchar2
  is
  begin
    return pl_requests_helpers.get_header( name            => name
                                         , headers_storage => self.headers );
  end get_header;
  
  /**
   * Sets global header for stored request
   * @param name header name
   * @param val header value
   */
  member procedure set_header( name in varchar2
                             , val  in varchar2 )
  is
  begin
    pl_requests_helpers.set_header( name            => name
                                  , val             => val
                                  , headers_storage => self.headers );
  end set_header;
  
  /**
   * Resolves provided url relative to specified base url
   * @param target target url
   * @return resolved url
   */
  member function resolve( target varchar2
                                  default null )
                           return varchar2
  is
  begin
    return pl_requests_helpers.resolve_url( path     => target
                                          , base_url => self.base_url );
  end resolve;

  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param headers response headers output
   * @param status response status output
   * @param body response body output
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param data (default null) request data to send in body
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , headers     in out nocopy pl_requests_http_headers
                          , status      in out nocopy number
                          , body        in out nocopy varchar2
                          , data        in            varchar2
                                                      default null
                          , mime_type   in            varchar2
                                                      default null
                          , charset     in            varchar2
                                                      default null
                          , chunked     in            boolean
                                                      default null
                          , req_headers in            pl_requests_http_headers
                                                      default null )
  is
    ctx       utl_http.request_context_key := null;
    l_headers pl_requests_http_headers;
  begin
    status := null;
    body   := null;

    if  self.wallet_path is not null 
    and self.wallet_password is not null
    then
      ctx := utl_http.create_request_context( wallet_path     => self.wallet_path
                                            , wallet_password => self.wallet_password );
    end if;

    if  req_headers is not null
    and req_headers.count > 0
    then
      l_headers := pl_requests_helpers.merge_headers( self.headers, req_headers );
    else
      l_headers := self.headers;
    end if;

    pl_requests.request( method      => method
                       , url         => self.resolve( url )
                       , req_headers => l_headers
                       , req_data    => data
                       , res_headers => headers
                       , res_status  => status
                       , res_body    => body
                       , ctx         => ctx
                       , charset     => coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )
                       , chunked     => coalesce( chunked, ( case when self.chunked = 'T' then true else false end ), false )
                       , mime_type   => coalesce( mime_type, self.mime_type ) );
    
    if ctx is not null
    then
      utl_http.destroy_request_context( ctx );
    end if;
  exception
    when OTHERS then
      if ctx is not null
      then
        utl_http.destroy_request_context( ctx );
      end if;
      raise;
  end request;
  
  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param status response status output
   * @param body response body output
   * @param data (default null) request data to send in body
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , status      in out nocopy number
                          , body        in out nocopy varchar2
                          , data        in            varchar2
                                                      default null
                          , mime_type   in            varchar2
                                                      default null
                          , charset     in            varchar2
                                                      default null
                          , chunked     in            boolean
                                                      default null
                          , req_headers in            pl_requests_http_headers
                                                      default null )
  is
    ctx       utl_http.request_context_key := null;
    l_headers pl_requests_http_headers;
  begin
    status := null;
    body   := null;

    if  self.wallet_path is not null 
    and self.wallet_password is not null
    then
      ctx := utl_http.create_request_context( wallet_path     => self.wallet_path
                                            , wallet_password => self.wallet_password );
    end if;

    if  req_headers is not null
    and req_headers.count > 0
    then
      l_headers := pl_requests_helpers.merge_headers( self.headers, req_headers );
    else
      l_headers := self.headers;
    end if;

    pl_requests.request( method      => method
                       , url         => self.resolve( url )
                       , req_headers => l_headers
                       , req_data    => data
                       , res_status  => status
                       , res_body    => body
                       , ctx         => ctx
                       , charset     => coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )
                       , chunked     => coalesce( chunked, ( case when self.chunked = 'T' then true else false end ), false )
                       , mime_type   => coalesce( mime_type, self.mime_type ) );
    
    if ctx is not null
    then
      utl_http.destroy_request_context( ctx );
    end if;
  exception
    when OTHERS then
      if ctx is not null
      then
        utl_http.destroy_request_context( ctx );
      end if;
      raise;
  end request;

  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param headers response headers output
   * @param status response status output
   * @param body response body output
   * @param data (default null) request data to send in body
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , headers     in out nocopy pl_requests_http_headers
                          , status      in out nocopy number
                          , body        in out nocopy clob
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
  is
    ctx       utl_http.request_context_key := null;
    l_headers pl_requests_http_headers;
  begin
    status := null;

    if  self.wallet_path is not null 
    and self.wallet_password is not null
    then
      ctx := utl_http.create_request_context( wallet_path     => self.wallet_path
                                            , wallet_password => self.wallet_password );
    end if;

    if  req_headers is not null
    and req_headers.count > 0
    then
      l_headers := pl_requests_helpers.merge_headers( self.headers, req_headers );
    else
      l_headers := self.headers;
    end if;

    pl_requests.request( method      => method
                       , url         => self.resolve( url )
                       , req_headers => l_headers
                       , req_data    => data
                       , res_headers => headers
                       , res_status  => status
                       , res_body    => body
                       , ctx         => ctx
                       , charset     => coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )
                       , chunked     => coalesce( chunked, ( case when self.chunked = 'T' then true else false end ), false )
                       , mime_type   => coalesce( mime_type, self.mime_type ) );
    
    if ctx is not null
    then
      utl_http.destroy_request_context( ctx );
    end if;
  exception
    when OTHERS then
      if ctx is not null
      then
        utl_http.destroy_request_context( ctx );
      end if;
      raise;
  end request;
  
  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param status response status output
   * @param body response body output
   * @param data (default null) request data to send in body
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , status      in out nocopy number
                          , body        in out nocopy clob
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
  is
    ctx       utl_http.request_context_key := null;
    l_headers pl_requests_http_headers;
  begin
    status := null;

    if  self.wallet_path is not null 
    and self.wallet_password is not null
    then
      ctx := utl_http.create_request_context( wallet_path     => self.wallet_path
                                            , wallet_password => self.wallet_password );
    end if;

    if  req_headers is not null
    and req_headers.count > 0
    then
      l_headers := pl_requests_helpers.merge_headers( self.headers, req_headers );
    else
      l_headers := self.headers;
    end if;

    pl_requests.request( method      => method
                       , url         => self.resolve( url )
                       , req_headers => l_headers
                       , req_data    => data
                       , res_status  => status
                       , res_body    => body
                       , ctx         => ctx
                       , charset     => coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )
                       , chunked     => coalesce( chunked, ( case when self.chunked = 'T' then true else false end ), false )
                       , mime_type   => coalesce( mime_type, self.mime_type ) );
    
    if ctx is not null
    then
      utl_http.destroy_request_context( ctx );
    end if;
  exception
    when OTHERS then
      if ctx is not null
      then
        utl_http.destroy_request_context( ctx );
      end if;
      raise;
  end request;
end;
/
