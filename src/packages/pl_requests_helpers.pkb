create or replace
package body pl_requests_helpers
is
  /**
   * Resolves and partly normalizes url path
   * @param url url path part
   * @param base_url (optional) base url
   * @return full url string
   */
  function resolve_url( path     in varchar2
                      , base_url in varchar2
                                    default null )
                        return varchar2
  is
    l_protocol varchar2(32);
    l_host     varchar2(1024);
    l_path     varchar2(4000);
    l_query    varchar2(4000);
  begin
    l_protocol := parse_url( nvl( base_url, path ), 'protocol' );
    l_host     := parse_url( nvl( base_url, path ), 'host' );
    l_query    := parse_url( path, 'query' );

    l_path := parse_url( path, 'path' );
    l_path := parse_url( base_url, 'path' ) ||
              ( case when l_path is null then null else '/' end ) ||
              l_path;

    return l_protocol ||
           l_host     ||
           regexp_replace( ( case when l_path is null then null else '/' end ) || l_path
                         , '/+'
                         , '/' ) ||
           l_query;
  end resolve_url;

  /**
   * Gets url part
   * @param url full url path
   * @param token part to retrieve from path (host, protocol, path, query)
   * @return url part value or null if not found
   */
  function parse_url( url   in varchar2
                    , token in varchar2 )
                      return varchar2
  is
    c_regexp constant varchar2(128) := '^(([a-z]*?:/+)([^/\?]*))?([^\?]*)(\?.*)?';
  begin
    return regexp_substr( 
      url, c_regexp, 1, 1, null, (
        case 
          when upper( token ) = 'PROTOCOL' 
            then gc_PROTOCOL
          when upper( token ) = 'HOST'
            then gc_HOST
          when upper( token ) = 'PATH' 
            then gc_PATH
          when upper( token ) = 'QUERY' 
            then gc_QUERY
          else null
        end
      ) 
    );
  end parse_url;

  /**
   * Sets header value in storage
   * @param name header name
   * @param val header value
   * @param headers_storage target headers collection
   * @param append (default false) appends header value to existing instance in collection
   */
  procedure set_header( name            in            varchar2
                      , val             in            varchar2
                      , headers_storage in out nocopy pl_request_headers
                      , append          in            boolean
                                                      default false )
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
          if nvl( append, false ) and val is not null 
          then
            headers_storage(i)."VALUE" := substrb(
              ( case 
                  when headers_storage(i)."VALUE" is not null 
                    then headers_storage(i)."VALUE" || ', ' || val
                  else val
                end )
              , 1
              , 4000
            );
          elsif not nvl( append, false )
          then
            headers_storage(i)."VALUE" := substrb( val, 1, 4000 );
          end if;
          return;
        end if;
      end loop;
    end if;
    
    headers_storage.extend();
    headers_storage(headers_storage.last) := pl_request_header( "NAME"  => name
                                                              , "VALUE" => substrb( val, 1, 4000 ) );
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

  /**
   * "Merges" two request headers storage into one.
   * Header values present both in left and right will be overriden by value from right.
   * @param l left storage
   * @param r (default null) right storage
   * @return merged storage
   */
  function merge_headers( l in pl_request_headers
                        , r in pl_request_headers
                               default null )
                          return pl_request_headers
  is
    headers pl_request_headers;
  begin
    if r is null or r.count = 0
    then
      return l;
    elsif l is null or l.count = 0 
    then
      return r;  
    end if;

    with lh as (
      select distinct st."NAME", st."VALUE" from table( l ) st
       where st."VALUE" is not null
    ), rh as (
      select distinct st."NAME", st."VALUE" from table( r ) st
    ), merged as (
      select lh."NAME" 
             as "NAME"
           , ( case when rh."NAME" is null then lh."VALUE" else rh."VALUE" end )
             as "VALUE"
        from lh
      left join rh on upper( lh."NAME" ) = upper( rh."NAME" )
      union
      select rh."NAME", rh."VALUE" 
        from rh
       where not exists ( select 't' from lh
                           where upper( lh."NAME" ) = upper( rh."NAME" ) )
    )
    select pl_request_header( merged."NAME", merged."VALUE" )
      bulk collect into headers
      from merged
     where merged."VALUE" is not null;

    return headers;
  end merge_headers;
end pl_requests_helpers;
/