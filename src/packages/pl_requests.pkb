create or replace
package body pl_requests
is
  g_DB_CHARSET nls_database_parameters."VALUE"%TYPE;

  /**
   * Converts custom charset alias to specific character set to be used
   * @param charset custom charset alias
   * @return db charset name on success, otherwise initial value is returned
   */
  function convert_charset_name( charset in varchar2 )
                                 return nls_database_parameters."VALUE"%TYPE
  is
  begin
    return (
      case 
        when upper( charset ) = 'UTF-8'
          then 'AL32UTF8'
        else 
          charset
      end
    );
  end convert_charset_name;

  /**
   * Calculates content length for clob
   * @param body clob value
   * @param request charset to be used
   * @return content length in bytes
   */
  function calc_content_length( body    in clob
                              , charset in varchar2
                                           default gc_DEFAULT_CHARSET )
                                return number
  is
    c_CHUNK          constant number := 4000;
    l_length                  number := 0;
    l_offset                  number := 1;
    l_content_length          number := 0;
    l_charset                 nls_database_parameters."VALUE"%TYPE;
  begin
    if body is not null then
      l_charset := convert_charset_name( charset );
      l_length  := nvl( dbms_lob.getLength( body ), 0 );

      while l_offset <= l_length
      loop
        l_content_length := l_content_length + (
          case 
            when nvl( l_charset, g_DB_CHARSET ) = g_DB_CHARSET then
              lengthb( dbms_lob.substr( body, c_CHUNK, l_offset ) )
            else
              lengthb( 
                convert( dbms_lob.substr( body, c_CHUNK, l_offset )
                       , l_charset ) 
              )
          end 
        );
        l_offset := l_offset + c_CHUNK;
      end loop;
    end if;

    return l_content_length;
  end calc_content_length;

  /**
   * Calculates content length for varchar2
   * @param body string value
   * @param request charset to be used
   * @return content length in bytes
   */
  function calc_content_length( body    in varchar2
                              , charset in varchar2
                                           default gc_DEFAULT_CHARSET )
                                return number
  is
    l_charset nls_database_parameters."VALUE"%TYPE;
  begin
    l_charset := convert_charset_name( charset );
    return (
      case 
        when body is null then 
          0
        when nvl( l_charset, g_DB_CHARSET ) = g_DB_CHARSET then
          lengthb( body )
        else 
          lengthb( convert( body, l_charset ) )
      end
    );
  end calc_content_length;

  /**
   * Execute http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param req_headers (optional) request headers
   * @param res_status response status storage
   * @param res_body response body storage
   * @param ctx (optional) request context key
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , req_headers in            pl_request_headers
                                               default null
                   , res_status  in out nocopy number
                   , res_body    in out nocopy varchar2
                   , ctx         in            utl_http.request_context_key
                                               default null )
  is
    f_REQ_OPENED boolean := false;
    f_RES_OPENED boolean := false;
    req utl_http.req;
    res utl_http.resp;
  begin
    req := utl_http.begin_request( method          => upper( method )
                                 , url             => url
                                 , request_context => ctx );
    f_REQ_OPENED := true;

    -- Set request headers if specified
    if req_headers is not null
    then
      set_headers( req     => req
                 , headers => req_headers );
    end if;

    -- TODO: set body

    res          := utl_http.get_response( req );
    f_REQ_OPENED := false;
    f_RES_OPENED := true;
    res_status   := res.status_code;

    -- TODO: fetch response headers

    -- TODO: optionally skip body reading on some codes
    get_body( res  => res
            , body => res_body );
    
    utl_http.end_response( res );
    f_RES_OPENED := false;
  exception
    when OTHERS then
      if f_RES_OPENED
      then
        utl_http.end_response( res );
      elsif f_REQ_OPENED
      then
        utl_http.end_request( req );
      end if;
      raise;
  end request;

  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_headers output response headers storage
   * @param res_status output response status
   * @param res_body output response body clob
   * @param ctx (default null) request context key
   * @param req_headers (default null) request headers to be set
   * @param req_data (default null) request data clob to be sent in body
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_headers in out nocopy pl_request_headers
                   , res_status  in out nocopy number
                   , res_body    in out nocopy clob
                   , ctx         in            utl_http.request_context_key
                                               default null
                   , req_headers in            pl_request_headers
                                               default null
                   , req_data    in            clob
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET
                   , chunked     in            boolean
                                               default false )
  is
    f_REQ_OPENED boolean := false;
    f_RES_OPENED boolean := false;
    req utl_http.req;
    res utl_http.resp;
  begin
    req := utl_http.begin_request( method          => upper( method )
                                 , url             => url
                                 , request_context => ctx );
    f_REQ_OPENED := true;

    if req_headers is not null
    then
      set_headers( req     => req
                 , headers => req_headers );
    end if;

    if req_data is not null
    or method = 'POST'
    then
      -- Theoretically, it's POSSIBLE to send body with HTTP GET
      -- On the other hand, HTTP POST always requires data sent in body
      set_body( req     => req
              , body    => req_data
              , charset => charset
              , chunked => chunked );
    end if;

    res          := utl_http.get_response( req );
    f_REQ_OPENED := false;
    f_RES_OPENED := true;
    res_status   := res.status_code;

    get_headers( res     => res
               , headers => res_headers );

    get_body( res     => res
            , body    => res_body
            , charset => charset );
    
    utl_http.end_response( res );
    f_RES_OPENED := false;
  exception
    when OTHERS then
      if f_RES_OPENED 
      then
        utl_http.end_response( res );
      elsif f_REQ_OPENED
      then
        utl_http.end_request( req );  
      end if;
      raise;
  end request;

  /**
   * Executes http request
   * @param method http method (GET, POST, PUT, PATCH, DELETE, OPTIONS)
   * @param url target url
   * @param res_headers output response headers storage
   * @param res_status output response status
   * @param res_body output response body text
   * @param ctx (default null) request context key
   * @param req_headers (default null) request headers to be set
   * @param req_data (default null) request data text to be sent in body
   * @param charset (default 'UTF-8') charset to be used for request and response bodies
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure request( method      in            varchar2
                   , url         in            varchar2
                   , res_headers in out nocopy pl_request_headers
                   , res_status  in out nocopy number
                   , res_body    in out nocopy varchar2
                   , ctx         in            utl_http.request_context_key
                                               default null
                   , req_headers in            pl_request_headers
                                               default null
                   , req_data    in            varchar2
                                               default null
                   , charset     in            varchar2
                                               default gc_DEFAULT_CHARSET
                   , chunked     in            boolean
                                               default false )
  is
    l_res_body clob;
  begin
    res_body := null;
    dbms_lob.createTemporary( lob_loc => l_res_body
                            , cache   => true
                            , dur     => dbms_lob.CALL );
    
    request( method      => method
           , url         => url
           , ctx         => ctx
           , charset     => charset
           , req_headers => req_headers
           , req_data    => to_clob( req_data )
           , res_headers => res_headers
           , res_status  => res_status
           , res_body    => l_res_body );
    
    res_body := l_res_body;
    dbms_lob.freeTemporary( l_res_body );
  exception
    when OTHERS then
      dbms_lob.freeTemporary( l_res_body );
      raise;
  end request;
  
  /**
   * Collects all response headers from response to headers collection
   * @param res response object
   * @param headers destination headers collection
   */
  procedure get_headers( res     in out nocopy utl_http.resp
                       , headers in out nocopy pl_request_headers )
  is
    l_name  varchar2(256);
    l_value varchar2(4000);
  begin
    if headers is null
    then
      headers := pl_request_headers();
    end if;

    for i in 1 .. utl_http.get_header_count( res )
    loop
      begin
        utl_http.get_header( res, i, l_name, l_value );
        pl_requests_helpers.set_header( name            => l_name
                                      , val             => l_value
                                      , headers_storage => headers
                                      , append          => true );
      exception
        when OTHERS then
          continue;
      end;
    end loop;
  end get_headers;

  /**
   * Reads response body into a clob variable
   * @param res response object
   * @param body output clob (must be allocated before call)
   * @param charset (default 'UTF-8') body charset
   */
  procedure get_body( res     in out nocopy utl_http.resp
                    , body    in out nocopy clob
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET )
  is
    l_chunk varchar2(32767);
  begin
    if charset is not null
    then
      utl_http.set_body_charset( r       => res
                               , charset => charset );
    end if;

    loop
      utl_http.read_text( r    => res
                        , data => l_chunk );
      dbms_lob.writeAppend( lob_loc => body
                          , amount  => length( l_chunk )
                          , buffer  => l_chunk );
    end loop;
  exception
    when utl_http.end_of_body then
      null;
  end get_body;

  /**
   * Reads response body as text into string variable
   * @param res response object
   * @param body output buffer 
   * @param charset (default 'UTF-8') body charset
   */
  procedure get_body( res     in out nocopy utl_http.resp
                    , body    in out nocopy varchar2
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET )
  is
    l_chunk varchar2(32767);
  begin
    if charset is not null
    then
      utl_http.set_body_charset( r       => res
                               , charset => charset );
    end if;

    body := null;
    loop
      utl_http.read_line( res, l_chunk );
      body := body || l_chunk;
    end loop;
  exception
    when utl_http.end_of_body then
      null;
  end get_body;

  /**
   * Reads response body into blob
   * @param res response object
   * @param body destination 
   */
  procedure get_body( res  in out nocopy utl_http.resp
                    , body in out nocopy blob )
  is
    l_chunk raw(32767);
  begin
    loop
      utl_http.read_raw( res, l_chunk, gc_CHUNK_SIZE );
      dbms_lob.writeAppend( body, utl_raw.length( l_chunk ), l_chunk );
    end loop;
  exception
    when utl_http.end_of_body then
      null;
  end get_body;

  /**
   * Sets request headers
   * @param req request object
   * @param headers headers collection
   */
  procedure set_headers( req     in out nocopy utl_http.req
                       , headers in            pl_request_headers )
  is
  begin
    if headers is not null and headers.count > 0
    then
      for header in ( select h."NAME"
                           , h."VALUE"
                        from table( headers ) h
                       where h."VALUE" is not null )
      loop
        utl_http.set_header( req, header."NAME", header."VALUE" );
      end loop;
    end if;
  end set_headers;

  /**
   * Sets request body from string
   * @param req request object
   * @param body string body to set
   * @param charset (default 'UTF-8') request body charset to use
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure set_body( req     in out nocopy utl_http.req
                    , body    in            clob
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET
                    , chunked in            boolean
                                            default false )
  is
    l_offset number := 1;
    l_length number := 0;
    l_bytes  number := 0;
  begin
    l_length := nvl( dbms_lob.getLength( body ), 0 );
    l_bytes  := calc_content_length( body    => body
                                   , charset => charset );
    
    if charset is not null
    then
      utl_http.set_body_charset( r       => req
                               , charset => charset );
    end if;

    if nvl( chunked, false )
    or l_bytes > gc_CHUNK_MAX_BYTES
    then
      utl_http.set_header( req, 'Transfer-Encoding', 'chunked' );
      
      declare
        l_chunk varchar2(32767);
      begin
        while l_offset <= l_length
        loop
          l_chunk := dbms_lob.substr( lob_loc => body
                                    , amount  => gc_CHUNK_SIZE
                                    , offset  => l_offset );
          l_offset := l_offset + length( l_chunk );
          utl_http.write_text( req, l_chunk );
        end loop;
      end;
    else
      utl_http.set_header( req, 'Content-Length', to_char(l_bytes) );
      
      if l_bytes > 0 then
        utl_http.write_text( req, body );
      end if;
    end if;
  end set_body;

  /**
   * Sets request body from string
   * @param req request object
   * @param body string body to set
   * @param charset (default 'UTF-8') request body charset to use
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure set_body( req     in out nocopy utl_http.req
                    , body    in            varchar2
                    , charset in            varchar2
                                            default gc_DEFAULT_CHARSET
                    , chunked in            boolean
                                            default false )
  is
    l_bytes number := 0;
  begin
    l_bytes := calc_content_length( body    => body
                                  , charset => charset );
    
    if charset is not null
    then
      utl_http.set_body_charset( r       => req
                               , charset => charset );
    end if;

    if chunked
    then
      utl_http.set_header( req, 'Transfer-Encoding', 'chunked' );
    else
      utl_http.set_header( req, 'Content-Length', to_char(l_bytes) );
    end if;
    
    if l_bytes > 0
    then
      utl_http.write_text( req, body );
    end if;
  end set_body;
  
  /**
   * Sets request body from blob
   * @param req request object
   * @param body blob body to set
   * @param chunked (default false) force Transfer-Encoding: chunked
   */
  procedure set_body( req     in out nocopy utl_http.req
                    , body    in            blob
                    , chunked in            boolean
                                            default false )
  is
    l_bytes  number         := 0;
    l_offset integer        := 1;
    l_amount binary_integer := 0;
    l_chunk  raw(32767);
  begin
    l_bytes := nvl( dbms_lob.getLength( body ), 0 );

    if nvl( chunked, false )
    or l_bytes > gc_CHUNK_MAX_BYTES
    then
      utl_http.set_header( req, 'Transfer-Encoding', 'chunked' );
    else
      utl_http.set_header( req, 'Content-Length', to_char(l_bytes) );
    end if;

    if body is not null
    then
      while l_offset <= l_bytes
      loop
        dbms_lob.read( lob_loc => body
                     , amount  => l_amount
                     , offset  => l_offset
                     , buffer  => l_chunk );
        utl_http.write_raw( req, l_chunk );
        l_offset := l_offset + l_amount;
      end loop;
    end if;
  end set_body;

-- Package init
begin
  -- Save database charset to a global variable
  begin  
    select ndp."VALUE"
      into g_DB_CHARSET
      from nls_database_parameters ndp
     where ndp."PARAMETER" = 'NLS_CHARACTERSET';
  exception
    when OTHERS then
      null;
  end;
end pl_requests;
/
