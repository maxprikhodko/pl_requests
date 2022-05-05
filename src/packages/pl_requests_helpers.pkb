create or replace
package body pl_requests_helpers
is
  /**
   * Returns matching document MIME type
   * @return matched mime type or initial value
   */
  function MIME( name in varchar2 )
                 return varchar2
  is
    l_name constant varchar2(256) := substrb(trim(upper(name)), 1, 256);
  begin
    if not regexp_like( l_name, '^\.?[A-Z0-9]+$' )
    then
      return name;
    end if;

    return (
      case
        -- Commom types
        when l_name in ( '.TXT', 'TXT', 'TEXT' ) then 'text/plain'
        when l_name in ( '.JSON', 'JSON' ) then 'application/json'
        when l_name in ( '.XML', 'XML' ) then 'application/xml'
        when l_name in ( '.CSV', 'CSV' ) then 'text/csv'
        -- Other possible types
        when l_name in ( '.AAC', 'AAC' ) then 'audio/aac'
        when l_name in ( '.ABW', 'ABW' ) then 'application/x-abiword'
        when l_name in ( '.ARC', 'ARC' ) then 'application/x-freearc'
        when l_name in ( '.AVIF', 'AVIF' ) then 'image/avif'
        when l_name in ( '.AVI', 'AVI' ) then 'video/x-msvideo'
        when l_name in ( '.AZW', 'AZW' ) then 'application/vnd.amazon.ebook'
        when l_name in ( '.BIN', 'BIN' ) then 'application/octet-stream'
        when l_name in ( '.BMP', 'BMP' ) then 'image/bmp'
        when l_name in ( '.BZ', 'BZ' ) then 'application/x-bzip'
        when l_name in ( '.BZ2', 'BZ2' ) then 'application/x-bzip2'
        when l_name in ( '.CDA', 'CDA' ) then 'application/x-cdf'
        when l_name in ( '.CSH', 'CSH' ) then 'application/x-csh'
        when l_name in ( '.CSS', 'CSS' ) then 'text/css'
        when l_name in ( '.DOC', 'DOC' ) then 'application/msword'
        when l_name in ( '.DOCX', 'DOCX' ) then 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
        when l_name in ( '.EOT', 'EOT' ) then 'application/vnd.ms-fontobject'
        when l_name in ( '.EPUB', 'EPUB' ) then 'application/epub+zip'
        when l_name in ( '.GZ', 'GZ' ) then 'application/gzip'
        when l_name in ( '.GIF', 'GIF' ) then 'image/gif'
        when l_name in ( '.HTM', '.HTML', 'HTM', 'HTML' ) then 'text/html'
        when l_name in ( '.ICO', 'ICO' ) then 'image/vnd.microsoft.icon'
        when l_name in ( '.ICS', 'ICS' ) then 'text/calendar'
        when l_name in ( '.JAR', 'JAR' ) then 'application/java-archive'
        when l_name in ( '.JPEG', '.JPG', 'JPEG', 'JPG' ) then 'image/jpeg'
        when l_name in ( '.JS', 'JS' ) then 'text/javascript'
        when l_name in ( '.JSONLD', 'JSONLD' ) then 'application/ld+json'
        when l_name in ( '.MID', '.MIDI', 'MID', 'MIDI' ) then 'audio/midi audio/x-midi'
        when l_name in ( '.MJS', 'MJS' ) then 'text/javascript'
        when l_name in ( '.MP3', 'MP3' ) then 'audio/mpeg'
        when l_name in ( '.MP4', 'MP4' ) then 'video/mp4'
        when l_name in ( '.MPEG', 'MPEG' ) then 'video/mpeg'
        when l_name in ( '.MPKG', 'MPKG' ) then 'application/vnd.apple.installer+xml'
        when l_name in ( '.ODP', 'ODP' ) then 'application/vnd.oasis.opendocument.presentation'
        when l_name in ( '.ODS', 'ODS' ) then 'application/vnd.oasis.opendocument.spreadsheet'
        when l_name in ( '.ODT', 'ODT' ) then 'application/vnd.oasis.opendocument.text'
        when l_name in ( '.OGA', 'OGA' ) then 'audio/ogg'
        when l_name in ( '.OGV', 'OGV' ) then 'video/ogg'
        when l_name in ( '.OGX', 'OGX' ) then 'application/ogg'
        when l_name in ( '.OPUS', 'OPUS' ) then 'audio/opus'
        when l_name in ( '.OTF', 'OTF' ) then 'font/otf'
        when l_name in ( '.PNG', 'PNG' ) then 'image/png'
        when l_name in ( '.PDF', 'PDF' ) then 'application/pdf'
        when l_name in ( '.PHP', 'PHP' ) then 'application/x-httpd-php'
        when l_name in ( '.PPT', 'PPT' ) then 'application/vnd.ms-powerpoint'
        when l_name in ( '.PPTX', 'PPTX' ) then 'application/vnd.openxmlformats-officedocument.presentationml.presentation'
        when l_name in ( '.RAR', 'RAR' ) then 'application/vnd.rar'
        when l_name in ( '.RTF', 'RTF' ) then 'application/rtf'
        when l_name in ( '.SH', 'SH' ) then 'application/x-sh'
        when l_name in ( '.SVG', 'SVG' ) then 'image/svg+xml'
        when l_name in ( '.SWF', 'SWF' ) then 'application/x-shockwave-flash'
        when l_name in ( '.TAR', 'TAR' ) then 'application/x-tar'
        when l_name in ( '.TIF', '.TIFF', 'TIF', 'TIFF' ) then 'image/tiff'
        when l_name in ( '.TS', 'TS' ) then 'video/mp2t'
        when l_name in ( '.TTF', 'TTF' ) then 'font/ttf'
        when l_name in ( '.VSD', 'VSD' ) then 'application/vnd.visio'
        when l_name in ( '.WAV', 'WAV' ) then 'audio/wav'
        when l_name in ( '.WEBA', 'WEBA' ) then 'audio/webm'
        when l_name in ( '.WEBM', 'WEBM' ) then 'video/webm'
        when l_name in ( '.WEBP', 'WEBP' ) then 'image/webp'
        when l_name in ( '.WOFF', 'WOFF' ) then 'font/woff'
        when l_name in ( '.WOFF2', 'WOFF2' ) then 'font/woff2'
        when l_name in ( '.XHTML', 'XHTML' ) then 'application/xhtml+xml'
        when l_name in ( '.XLS', 'XLS' ) then 'application/vnd.ms-excel'
        when l_name in ( '.XLSX', 'XLSX' ) then 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        when l_name in ( '.XUL', 'XUL' ) then 'application/vnd.mozilla.xul+xml'
        when l_name in ( '.ZIP', 'ZIP' ) then 'application/zip'
        when l_name in ( '.3GP', '3GP' ) then 'video/3gpp'
        when l_name in ( '.3G2', '3G2' ) then 'video/3gpp2'
        when l_name in ( '.7Z', '7Z' ) then 'application/x-7z-compressed'
        else name
      end
    );
  end MIME;

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