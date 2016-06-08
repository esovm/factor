! Copyright (C) 2007, 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.strings arrays
byte-arrays hashtables io io.encodings.string kernel math
namespaces sequences strings continuations x11 x11.xlib
accessors io.encodings.utf8 literals ;
in: x11.xim

SYMBOL: xim

: (init-xim) ( classname medifier -- im )
    XSetLocaleModifiers [ "XSetLocaleModifiers() failed" throw ] unless
    [ dpy get f ] dip dup XOpenIM ;

: init-xim ( classname -- )
    dup "" (init-xim)
    [ nip ]
    [ "@im=none" (init-xim) [ "XOpenIM() failed" throw ] unless* ] if*
    xim set-global ;

: close-xim ( -- )
    xim get-global XCloseIM drop f xim set-global ;

: with-xim ( quot -- )
    [ "Factor" init-xim ] dip [ close-xim ] [ ] cleanup ; inline

: create-xic ( window classname -- xic )
    [
        [ xim get-global XNClientWindow ] dip
        XNFocusWindow over
        XNInputStyle XIMPreeditNothing XIMStatusNothing bitor
        XNResourceName
    ] dip
    XNResourceClass over 0 XCreateIC
    [ "XCreateIC() failed" throw ] unless* ;

<<
CONSTANT: buf-size 100
>>

CONSTANT: buf $[ buf-size <byte-array> ]

: lookup-string ( event xic -- string keysym )
    swap buf buf-size { KeySym } [ 0 int <ref>
        Xutf8LookupString buf swap head utf8 decode
    ] with-out-parameters ;