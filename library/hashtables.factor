! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004, 2005 Slava Pestov.
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

IN: hashtables
USE: generic
USE: kernel
USE: lists
USE: math
USE: vectors

BUILTIN: hashtable 10

! A hashtable is implemented as an array of buckets. The
! array index is determined using a hash function, and the
! buckets are associative lists which are searched
! linearly.

! The unsafe words go in kernel internals. Everything else, even
! if it is somewhat 'implementation detail', is in the
! public 'hashtables' vocabulary.

IN: kernel-internals

: hash-array 2 slot ; inline
: set-hash-array 2 set-slot ; inline

: hash-bucket ( n hash -- alist )
    swap >fixnum swap >hashtable hash-array array-nth ; inline

: set-hash-bucket ( obj n hash -- )
    swap >fixnum swap >hashtable hash-array set-array-nth ;
    inline

: change-bucket ( n hash quot -- )
    -rot hash-array
    [ array-nth swap call ] 2keep
    set-array-nth ; inline

IN: hashtables

: hash-size+ ( hash -- )
    >hashtable dup 1 slot 1 + swap 1 set-slot ; inline

: hash-size- ( hash -- )
    >hashtable dup 1 slot 1 - swap 1 set-slot ; inline

: hash-size ( hash -- n )
    #! Number of elements in the hashtable.
    >hashtable 1 slot ;

: bucket-count ( hash -- n )
    >hashtable hash-array array-capacity ; inline

: (hashcode) ( key table -- index )
    #! Compute the index of the bucket for a key.
    >r hashcode r> bucket-count rem ; inline

: hash* ( key table -- [[ key value ]] )
    #! Look up a value in the hashtable. First the bucket is
    #! determined using the hash function, then the association
    #! list therein is searched linearly.
    2dup (hashcode) swap hash-bucket assoc* ;

: hash ( key table -- value )
    #! Unlike hash*, this word cannot distinglish between an
    #! undefined value, or a value set to f.
    hash* dup [ cdr ] when ;

: set-hash* ( key hash quot -- )
    #! Apply the quotation to yield a new association list.
    #! If the association list already contains the key,
    #! decrement the hash size, since it will get removed.
    -rot 2dup (hashcode) over [
        ( quot key hash assoc -- )
        swapd 2dup
        assoc [ rot hash-size- ] [ rot drop ] ifte
        rot call
    ] change-bucket ; inline

: rehash? ( hash -- ? )
    dup bucket-count 3 * 2 /i swap hash-size < ;

: grow-hash ( hash -- )
    #! A good way to earn a living.
    dup hash-size 2 * <array> swap set-hash-array ;

: (hash>alist) ( alist n hash -- alist )
    2dup bucket-count >= [
        2drop
    ] [
        [ hash-bucket [ swons ] each ] 2keep
        >r 1 + r> (hash>alist)
    ] ifte ;

: hash>alist ( hash -- alist )
    #! Push a list of key/value pairs in a hashtable.
    [ ] 0 rot (hash>alist) ;

: (set-hash) ( value key hash -- )
    dup hash-size+ [ set-assoc ] set-hash* ;

: rehash ( hash -- )
    #! Increase the hashtable size if its too small.
    dup rehash? [
        dup hash>alist over grow-hash
        [ unswons rot (set-hash) ] each-with
    ] [
        drop
    ] ifte ;

: set-hash ( value key table -- )
    #! Store the value in the hashtable. Either replaces an
    #! existing value in the appropriate bucket, or adds a new
    #! key/value pair.
    dup rehash (set-hash) ;

: remove-hash ( key table -- )
    #! Remove a value from a hashtable.
    [ remove-assoc ] set-hash* ;

: hash-clear ( hash -- )
    #! Remove all entries from a hashtable.
    dup bucket-count [
        [ f swap pick set-hash-bucket ] keep
    ] repeat drop ;

: buckets>list ( hash -- list )
    #! Push a list of key/value pairs in a hashtable.
    dup bucket-count swap hash-array array>list ;

: alist>hash ( alist -- hash )
    dup length 1 max <hashtable> swap
    [ unswons pick set-hash ] each ;

: hash-keys ( hash -- list )
    #! Push a list of keys in a hashtable.
    hash>alist [ car ] map ;

: hash-values ( hash -- alist )
    #! Push a list of values in a hashtable.
    hash>alist [ cdr ] map ;

: hash-each ( hash code -- )
    #! Apply the code to each key/value pair of the hashtable.
    >r hash>alist r> each ; inline

M: hashtable clone ( hash -- hash )
    dup bucket-count dup <hashtable> [
        hash-array rot hash-array rot copy-array
    ] keep ;

: hash-subset? ( subset of -- ? )
    hash>alist [ uncons >r swap hash r> = ] all-with? ;

M: hashtable = ( obj hash -- ? )
    2dup eq? [
        2drop t
    ] [
        over hashtable? [
            2dup hash-subset? >r swap hash-subset? r> and
        ] [
            2drop f
        ] ifte
    ] ifte ;
