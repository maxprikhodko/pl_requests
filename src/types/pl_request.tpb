create or replace
type body pl_request
is
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
