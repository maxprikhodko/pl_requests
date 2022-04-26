create or replace
type pl_request is object
(
    base_url varchar2(2048)

    /**
     * Resolves provided url relative to specified base url
     * @param target target url
     * @return resolved url
     */
  , member function resolve( target varchar2
                                    default null )
                             return varchar2
)
/
