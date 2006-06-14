! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays generic hashtables inspector io kernel namespaces
parser prettyprint sequences strings styles vectors words ;

! Simple markup language.

! <element> ::== <string> | <simple-element> | <fancy-element>
! <simple-element> ::== { <element>* }
! <fancy-element> ::== { <type> <element> }

! Element types are words whose name begins with $.

PREDICATE: array simple-element
    dup empty? [ drop t ] [ first word? not ] if ;

M: simple-element print-element [ print-element ] each ;
M: string print-element last-block off write ;
M: array print-element unclip execute ;
M: word print-element { } swap execute ;

: ($span) ( content style -- )
    last-block off [ print-element ] with-style ;

: ?terpri ( -- )
    last-block [ [ terpri ] unless t ] change ;

: ($block) ( quot -- )
    ?terpri
    call
    terpri
    last-block on ; inline

! Some spans

: $heading [ heading-style ($span) ] ($block) ;

: $snippet snippet-style ($span) ;

: $emphasis emphasis-style ($span) ;

: $url url-style ($span) ;

: $terpri last-block off terpri terpri drop ;

! Some blocks

: ($code) ( presentation quot -- )
    [
        code-style [
            >r presented associate r> with-nesting
        ] with-style
    ] ($block) ; inline

: $code ( content -- )
    "\n" join dup <input> [ write ] ($code) ;

: $syntax ( word -- )
    dup stack-effect [
        "Syntax" $heading
        >r word-name $snippet " " $snippet r> $snippet
    ] [
        drop
    ] if* ;

: $stack-effect ( word -- )
    stack-effect [
        "Stack effect" $heading $snippet
    ] when* ;

: $vocabulary ( content -- )
    first word-vocabulary [
        "Vocabulary" $heading $snippet
    ] when* ;

: $synopsis ( content -- )
    dup $vocabulary
    first dup parsing? [ $syntax ] [ $stack-effect ] if ;

: $description ( content -- )
    "Description" $heading print-element ;

: $contract ( content -- )
    "Contract" $heading print-element ;

: $examples ( content -- )
    "Examples" $heading print-element ;

: $warning ( content -- )
    [
        warning-style [
            "Warning" $heading print-element
        ] with-nesting
    ] ($block) ;

: textual-list ( seq quot -- )
    [ ", " print-element ] interleave ; inline

: $example ( content -- )
    1 swap cut* swap "\n" join dup <input> [
        input-style format terpri print-element
    ] ($code) ;

! Some links
TUPLE: link name ;

M: link article-title link-name article-title ;
M: link article-content link-name article-content ;
M: link summary
    link-name dup word?
    [ synopsis ] [ "Link to " swap unparse append ] if ;

: ($subsection) ( quot object -- )
    subsection-style [
        [ swap curry ] keep dup article-title swap <link>
        rot write-outliner
    ] with-style ;

: $subsection ( object -- )
    [
        first [ help ] swap ($subsection)
    ] ($block) ;

: $subtopic ( object -- )
    [
        subtopic-style [
            unclip f rot [ (help) ] curry write-outliner
        ] with-style
    ] ($block) ;

: $link ( article -- )
    last-block off first link-style
    [ dup article-title swap <link> write-object ] with-style ;

: $links ( content -- )
    [ 1array $link ] textual-list ;

: $see-also ( content -- )
    "See also" $heading $links ;

: $table ( content -- )
    ?terpri table-style [
        H{ } [ print-element ] tabular-output
    ] with-style ;

: $values ( content -- )
    "Arguments and values" $heading
    [ first2 >r \ $snippet swap 2array r> 2array ] map
    $table ;

: $predicate ( content -- )
    { { "object" "an object" } } $values
    [
        "Tests if the object is an instance of the " ,
        { $link } swap append ,
        " class." ,
    ] { } make $description ;

: $list ( content -- ) [  "-" swap 2array ] map $table ;

: $errors ( content -- )
    "Errors" $heading print-element ;

: $side-effects ( content -- )
    "Side effects" $heading "Modifies " print-element
    [ $snippet ] textual-list ;

: $notes ( content -- )
    "Notes" $heading print-element ;

: $see ( content -- )
    code-style [ first see ] with-nesting ;

: $definition ( content -- )
    "Definition" $heading $see ;

: $curious ( content -- )
    "For the curious..." $heading print-element ;

: $references ( content -- )
    "References" $heading
    unclip print-element [ \ $link swap 2array ] map $list ;

: $shuffle ( content -- )
    drop
    "Shuffle word. Re-arranges the stack according to the stack effect pattern." $description ;

: $low-level-note
    drop
    "Calling this word directly is not necessary in most cases. Higher-level words call it automatically." print-element ;

: $values-x/y
    drop
    { { "x" "a complex number" } { "y" "a complex number" } } $values ;

: $io-error
    drop
    "Throws an error if the I/O operation fails." $errors ;

: sort-articles ( seq -- assoc )
    [ [ article-title ] keep 2array ] map
    [ [ first ] 2apply <=> ] sort
    [ second ] map ;

: help-outliner ( seq quot -- | quot: obj -- )
    swap sort-articles [ ($subsection) terpri ] each-with ;

: $outliner ( content -- )
    first call [ help ] help-outliner ;
