! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2003 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: words
USE: hashtables
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: strings

: word-property ( word pname -- pvalue )
    swap word-plist assoc ;

: set-word-property ( word pvalue pname -- )
    pick word-plist
    pick [ set-assoc ] [ remove-assoc nip ] ifte
    swap set-word-plist ;

: ?word-primitive ( obj -- prim/0 )
    dup word? [ word-primitive ] [ drop -1 ] ifte ;

: compound?  ( obj -- ? ) ?word-primitive 1 = ;
: primitive? ( obj -- ? ) ?word-primitive 2 > ;
: symbol?    ( obj -- ? ) ?word-primitive 2 = ;
: undefined? ( obj -- ? ) ?word-primitive 0 = ;

: word ( -- word ) global [ "last-word" get ] bind ;
: set-word ( word -- ) global [ "last-word" set ] bind ;

: (define) ( word primitive parameter -- )
    #! Define a word in the current Factor instance.
    pick set-word-parameter
    over set-word-primitive
    f "parsing" set-word-property ;

: define ( word primitive parameter -- )
    #! The define-hook is set by the image bootstrapping code.
    "define-hook" get [ call ] [ (define) ] ifte* ;

: define-compound ( word def -- ) 1 swap define ;
: define-symbol   ( word -- ) 2 over define ;

: word-name       ( word -- str ) "name" word-property ;
: word-vocabulary ( word -- str ) "vocabulary" word-property ;
: stack-effect    ( word -- str ) "stack-effect" word-property ;
: documentation   ( word -- str ) "documentation" word-property ;

: vocabs ( -- list )
    #! Push a list of vocabularies.
    global [ "vocabularies" get hash-keys str-sort ] bind ;

: vocab ( name -- vocab )
    #! Get a vocabulary.
    global [ "vocabularies" get hash ] bind ;

: word-sort ( list -- list )
    #! Sort a list of words by name.
    [ swap word-name swap word-name str-lexi> ] sort ;

: words ( vocab -- list )
    #! Push a list of all words in a vocabulary.
    #! Filter empty slots.
    vocab hash-values [ ] subset word-sort ;

: each-word ( quot -- )
    #! Apply a quotation to each word in the image.
    vocabs [ words [ swap dup >r call r> ] each ] each drop ;

: init-search-path ( -- )
    ! For files
    "scratchpad" "file-in" set
    [ "builtins" "syntax" "scratchpad" ] "file-use" set
    ! For interactive
    "scratchpad" "in" set
    [
        "user"
        "arithmetic"
        "builtins"
        "compiler"
        "debugger"
        "errors"
        "files"
        "hashtables"
        "inference"
        "inferior"
        "interpreter"
        "inspector"
        "jedit"
        "kernel"
        "listener"
        "lists"
        "math"
        "namespaces"
        "parser"
        "prettyprint"
        "processes"
        "profiler"
        "stack"
        "streams"
        "stdio"
        "strings"
        "syntax"
        "test"
        "threads"
        "unparser"
        "vectors"
        "vocabularies"
        "words"
        "scratchpad"
    ] "use" set ;
