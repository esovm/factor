IN: scratchpad
USING: kernel alien parser compiler words sequences ;

"sqlite" "libsqlite3" add-simple-library

{
    "sqlite"
    "tuple-db"
} [ "/contrib/sqlite/" swap ".factor" append3 run-resource ] each
