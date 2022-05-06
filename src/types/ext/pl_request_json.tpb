create or replace
type body pl_request_json
is
  constructor function pl_request_json( base_url        varchar2
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
  end pl_request_json;

  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param headers response headers output
   * @param status response status output
   * @param body JSON response body output
   * @param data (default null) request data to send in body
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , headers     in out nocopy pl_request_headers
                          , status      in out nocopy number
                          , body        in out nocopy pljson
                          , data        in            clob
                                                      default null
                          , mime_type   in            varchar2
                                                      default null
                          , charset     in            varchar2
                                                      default null
                          , chunked     in            boolean
                                                      default null
                          , req_headers in            pl_request_headers
                                                      default null )
  is
    l_body clob;
  begin
    dbms_lob.createTemporary( lob_loc => l_body
                            , cache   => true
                            , dur     => dbms_lob.CALL );
    
    (self as pl_request).request( method      => method
                                , url         => url
                                , headers     => headers
                                , status      => status
                                , body        => l_body
                                , data        => data
                                , mime_type   => mime_type
                                , charset     => charset
                                , chunked     => chunked
                                , req_headers => req_headers );
    body := pljson( l_body );
    dbms_lob.freeTemporary( l_body );
  exception
    when OTHERS then
      dbms_lob.freeTemporary( l_body );
      raise;
  end request;
  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param status response status output
   * @param body JSON response body output
   * @param data (default null) request data to send in body
   * @param mime_type (default null) mime type to be specified in content-type header for request data
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , status      in out nocopy number
                          , body        in out nocopy pljson
                          , data        in            clob
                                                      default null
                          , mime_type   in            varchar2
                                                      default null
                          , charset     in            varchar2
                                                      default null
                          , chunked     in            boolean
                                                      default null
                          , req_headers in            pl_request_headers
                                                      default null )
  is
    l_body clob;
  begin
    dbms_lob.createTemporary( lob_loc => l_body
                            , cache   => true
                            , dur     => dbms_lob.CALL );
    
    (self as pl_request).request( method      => method
                                , url         => url
                                , status      => status
                                , body        => l_body
                                , data        => data
                                , mime_type   => mime_type
                                , charset     => charset
                                , chunked     => chunked
                                , req_headers => req_headers );

    body := pljson( l_body );
    dbms_lob.freeTemporary( l_body );
  exception
    when OTHERS then
      dbms_lob.freeTemporary( l_body );
      raise;
  end request;
  
  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param headers response headers output
   * @param status response status output
   * @param body JSON response body output
   * @param data (default null) JSON request data to send in body
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , headers     in out nocopy pl_request_headers
                          , status      in out nocopy number
                          , body        in out nocopy pljson
                          , data        in  pljson
                          , charset     in            varchar2
                                                      default null
                          , chunked     in            boolean
                                                      default null
                          , req_headers in            pl_request_headers
                                                      default null )
  is
    l_data clob := null;
  begin
    if data is not null
    then
      dbms_lob.createTemporary( lob_loc => l_data
                              , cache   => true
                              , dur     => dbms_lob.CALL );
      data.to_clob( l_data );
    end if;

    self.request( method      => method
                , url         => url
                , headers     => headers
                , status      => status
                , body        => body
                , data        => l_data
                , mime_type   => 'application/json'
                , charset     => charset
                , chunked     => chunked
                , req_headers => req_headers );

    if l_data is not null
    then
      dbms_lob.freeTemporary( l_data );
    end if;
  exception
    when OTHERS then
      if l_data is not null
      then
        dbms_lob.freeTemporary( l_data );
      end if;
      raise;
  end request;
  
  /**
   * Executes HTTP request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url relative url
   * @param status response status output
   * @param body JSON response body output
   * @param data (default null) JSON request data to send in body
   * @param charset (default null) charset to be used for request and response bodies
   * @param chunked (default null) force Transfer-Encoding: chunked
   * @param req_headers (default null) additional http headers
   */
  member procedure request( method      in            varchar2
                          , url         in            varchar2
                          , status      in out nocopy number
                          , body        in out nocopy pljson
                          , data        in  pljson
                          , charset     in            varchar2
                                                      default null
                          , chunked     in            boolean
                                                      default null
                          , req_headers in            pl_request_headers
                                                      default null )
  is
    l_data clob := null;
  begin
    if data is not null
    then
      dbms_lob.createTemporary( lob_loc => l_data
                              , cache   => true
                              , dur     => dbms_lob.CALL );
      data.to_clob( l_data );
    end if;

    self.request( method      => method
                , url         => url
                , status      => status
                , body        => body
                , data        => l_data
                , mime_type   => 'application/json'
                , charset     => charset
                , chunked     => chunked
                , req_headers => req_headers );

    if l_data is not null
    then
      dbms_lob.freeTemporary( l_data );
    end if;
  exception
    when OTHERS then
      if l_data is not null
      then
        dbms_lob.freeTemporary( l_data );
      end if;
      raise;
  end request;
end;
/
