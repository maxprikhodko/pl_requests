create or replace
type body pl_request
is
  /**
   * Creates a configured http service access instance
   * @param base_url base url
   * @param wallet_path (default null) wallet path
   * @param wallet_password (default null) wallet password
   * @param charset (default null) charset to be used by all child requests by default
   * @param chunked (default null) force Transfer-Encoding: chunked by default
   * @param mime_type (default 'plain/text') default mime type to be set for requests data
   * @param headers (default null) headers to be sent with all child requests
   * @return pl_request instance (configured http service access instance)
   */
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
                                                   default 'text/plain'
                                 , headers         pl_requests_http_headers
                                                   default null )
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

    if headers is not null and headers.count > 0
    then
      self.headers := headers;
    end if;
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

  /**
   * Executes http request. Fetches response body if response status matches the expected.
   * @param body output response body clob
   * @param expected output flag indicating if response status code matches the expected status mask. Null is set on exceptions
   * @param url relative url
   * @param status (default '2xx') expected response status mask. If set to null, any response status code is valid
   * @param method (default 'GET') http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param data (default null) request data to send in body
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) 'T'=true, 'F'=false - force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure fetch_clob( self        in            pl_request
                             , body        in out nocopy clob
                             , expected    in out nocopy boolean
                             , url         in            varchar2
                             , status      in            varchar2
                                                         default '2xx'
                             , method      in            varchar2
                                                         default 'GET'
                             , data        in            clob
                                                         default null
                             , mime_type   in            varchar2
                                                         default null
                             , charset     in            varchar2
                                                         default null
                             , chunked     in            varchar2
                                                         default null
                             , req_headers in            pl_requests_http_headers
                                                         default null )
  is
    ctx               utl_http.request_context_key := null;
    res               utl_http.resp;
    l_headers         pl_requests_http_headers;
    l_expected_status varchar2(32);
    l_status          number;
    l_chunked         boolean;
    l_opened          boolean := false;
  begin
    expected := null;

    if status is null  -- Any status
    then
      l_expected_status := '^[1-5][0-9]{2}$';
    elsif regexp_like( status, '^[1-5][0-9x]{2}$', 'i' ) 
    then
      l_expected_status := '^' || replace( upper(status), 'X', '[0-9]' ) || '$';
    else -- Invalid parameter - return without execution
      return;
    end if;

    l_chunked := coalesce(
        ( case when chunked = 'T' then true when chunked = 'F' then false else null end )
      , ( case when self.chunked = 'T' then true when self.chunked = 'F' then false else null end )
      , false
    );

    if req_headers is not null and req_headers.count > 0
    then
      l_headers := pl_requests_helpers.merge_headers( self.headers, req_headers );
    else
      l_headers := self.headers;
    end if;

    if  self.wallet_path is not null 
    and self.wallet_password is not null
    then
      ctx := utl_http.create_request_context( wallet_path     => self.wallet_path
                                            , wallet_password => self.wallet_password );
    end if;

    res := pl_requests.fetch_url( method    => method
                                , url       => self.resolve( url )
                                , opened    => l_opened
                                , headers   => l_headers
                                , data      => data
                                , charset   => coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET )
                                , chunked   => l_chunked
                                , mime_type => coalesce( mime_type, self.mime_type )
                                , ctx       => ctx );
    l_status := res.status_code;
    expected := regexp_like( to_char(l_status), l_expected_status, 'i' );

    if expected
    then
      pl_requests.get_body( res     => res
                          , body    => body
                          , charset => coalesce( charset, self.charset, pl_requests.DEFAULT_CHARSET ) );
    end if;

    utl_http.end_response( res );
    l_opened := false;

    if ctx is not null
    then
      utl_http.destroy_request_context( ctx );
      ctx := null;
    end if;
  exception
    when OTHERS then
      if l_opened
      then
        begin utl_http.end_response( res ); exception when OTHERS then null; end;
      end if;

      if ctx is not null
      then
        utl_http.destroy_request_context( ctx );
      end if;
      raise;
  end fetch_clob;

  /**
   * Executes HTTP request and returns response body if response status matches the expected.
   * Response body must not exceed 4000 bytes, otherwise it will be cut to fit buffer.
   * Returns null if any exception occures.
   * @param url relative url
   * @param status (default '2xx') expected response status mask
   * @param method (default 'GET') http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param alt (default null) alternative message to be returned if response status does not match the expected
   * @param data (default null) request data to send in body
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) 'T'=true, 'F'=false - force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   * @return response body string
   */
  member function fetch_response( url         in varchar2
                                , status      in varchar2
                                                 default '2xx'
                                , method      in varchar2
                                                 default 'GET'
                                , alt         in varchar2
                                                 default null
                                , data        in varchar2
                                                 default null
                                , mime_type   in varchar2
                                                 default null
                                , charset     in varchar2
                                                 default null
                                , chunked     in varchar2
                                                 default null 
                                , req_headers in pl_requests_http_headers
                                                 default null )
                                  return varchar2
  is
    l_expected boolean;
    l_body     clob;
    l_ret      varchar2(4000);
  begin
    dbms_lob.createTemporary( lob_loc => l_body
                            , cache   => true
                            , dur     => dbms_lob.CALL );

    self.fetch_clob( body        => l_body
                   , expected    => l_expected
                   , url         => url
                   , status      => status
                   , method      => method
                   , data        => to_clob( data )
                   , mime_type   => mime_type
                   , charset     => charset
                   , chunked     => chunked
                   , req_headers => req_headers );

    l_ret := (
      case 
        when l_expected is null 
          then null
        when l_expected 
          then substrb( dbms_lob.substr( l_body, 4000, 1 ), 1, 4000 )
        else alt
      end
    );

    dbms_lob.freeTemporary( l_body );
    return l_ret;
  exception
    when OTHERS then
      dbms_lob.freeTemporary( l_body );
      return null;
  end fetch_response;
end;
/
