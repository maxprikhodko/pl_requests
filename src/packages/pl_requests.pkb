create or replace
package body pl_requests
is
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
