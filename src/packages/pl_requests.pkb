create or replace
package body pl_requests
is
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
                                               default gc_DEFAULT_CHARSET )
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
                                               default gc_DEFAULT_CHARSET )
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
        headers.extend();
        headers(headers.last) := pl_request_header( l_name, l_value );
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
    l_buffer varchar2(32767);
  begin
    if charset is not null
    then
      utl_http.set_body_charset( r       => res
                               , charset => charset );
    end if;

    loop
      utl_http.read_text( r    => res
                        , data => l_buffer );
      dbms_lob.writeAppend( lob_loc => body
                          , amount  => length( l_buffer )
                          , buffer  => l_buffer );
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
    l_buffer varchar2(4000);
  begin
    if charset is not null
    then
      utl_http.set_body_charset( r       => res
                               , charset => charset );
    end if;

    body := null;
    loop
      utl_http.read_line( res, l_buffer );
      body := body || l_buffer;
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
   * Reads response body into blob
   * @param res response object
   * @param body destination 
   */
  procedure get_body( res  in out nocopy utl_http.resp
                    , body in out nocopy blob )
  is
    lc_CHUNK_SIZE constant number := 2048;
    l_buffer               raw(2048);
  begin
    loop
      utl_http.read_raw( res, l_buffer, lc_CHUNK_SIZE );
      dbms_lob.writeAppend( body, utl_raw.length( l_buffer ), l_buffer );
    end loop;
  exception
    when utl_http.end_of_body then
      null;
  end get_body;

  /**
   * Sets request body from string
   * @param req request object
   * @param body string body to set
   */
  procedure set_body( req  in out nocopy utl_http.req
                    , body in            varchar2 )
  is
  begin
    utl_http.set_header( req, 'Content-Length', to_char(lengthb(body)) );
    utl_http.write_text( req, body );
  end set_body;
  
  /**
   * Sets request body from blob
   * @param req request object
   * @param body blob body to set
   */
  procedure set_body( req  in out nocopy utl_http.req
                    , body in            blob )
  is
    lc_CHUNK_SIZE constant number := 32767;
    l_length               number := 0;
  begin
    l_length := dbms_lob.getLength( body );
    utl_http.set_header( req, 'Content-Length', to_char(l_length) );

    if l_length <= lc_CHUNK_SIZE
    then
      utl_http.write_raw( req, body );
    else
      declare
        l_offset integer := 0;
        l_amount integer := 0;
        l_buffer raw(32767);
      begin
        while l_offset < l_length
        loop
          dbms_lob.read( body, l_amount, l_offset, l_buffer );
          utl_http.write_raw( req, l_buffer );
          l_offset := l_offset + l_amount;
        end loop;
      end;
    end if;
  end set_body;
end pl_requests;
/
