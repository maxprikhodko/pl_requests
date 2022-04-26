create or replace
package body pl_requests_helpers
is
  /**
   * Sets header value in storage
   * @param name header name
   * @param val header value
   * @param headers_storage target headers collection
   */
  procedure set_header( name            in            varchar2
                      , val             in            varchar2
                      , headers_storage in out nocopy pl_request_headers )
  is
  begin
    if headers_storage is null
    then
      headers_storage := pl_request_headers();
    end if;
    
    if headers_storage.count > 0
    then
      for i in headers_storage.first .. headers_storage.last
      loop
        if upper( headers_storage(i)."NAME" ) = upper( name )
        then
          headers_storage(i)."VALUE" := val;
          return;
        end if;
      end loop;
    end if;
    
    headers_storage.extend();
    headers_storage(headers_storage.last) := pl_request_header( "NAME"  => name
                                                              , "VALUE" => val );
  end set_header;
  
  /**
   * Returns header value from collection
   * @param name header name
   * @param headers_storage source headers collection
   * @return header value or null if not found or uninitialized
   */
  function get_header( name            in            varchar2
                     , headers_storage in pl_request_headers )
                       return varchar2
  is
    c_name constant varchar2(256) := name;
    l_value         varchar2(4000);
  begin
    if headers_storage is null
    then
      return null;
    end if;
    
    begin
      select h."VALUE" 
        into l_value
        from table( headers_storage ) h
       where upper(h."NAME") = upper(c_name);
    exception
      when TOO_MANY_ROWS or NO_DATA_FOUND then
        l_value := null;
    end;

    return l_value;
  end get_header;
end pl_requests_helpers;
/