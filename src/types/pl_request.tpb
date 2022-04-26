create or replace
type body pl_request
is
  constructor function pl_request( base_url        varchar2
                                 , wallet_path     varchar2
                                                   default null
                                 , wallet_password varchar2
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
   * @param status response status output
   * @param body response body output
   */
  member procedure request( method in            varchar2
                          , url    in            varchar2
                          , status in out nocopy number
                          , body   in out nocopy varchar2 )
  is
    ctx utl_http.request_context_key := null;
  begin
    status := null;
    body   := null;

    if  self.wallet_path is not null 
    and self.wallet_password is not null
    then
      ctx := utl_http.create_request_context( wallet_path     => self.wallet_path
                                            , wallet_password => self.wallet_password );
    end if;

    pl_requests.request( method      => method
                       , url         => self.resolve( url )
                       , req_headers => self.headers
                       , res_status  => status
                       , res_body    => body
                       , ctx         => ctx );
    
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
