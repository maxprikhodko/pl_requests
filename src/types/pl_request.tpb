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
    return regexp_replace( self.base_url || '/' || target, '/+', '/' );
  end resolve;
end;
/
