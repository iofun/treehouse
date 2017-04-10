#! /bin/sh

DEMO_LIBS="./deps/*/ebin ./ebin"

# observer
exec erl -smp enable +stbt db -sname sim -setcookie ship-demo -pa $DEMO_LIBS
