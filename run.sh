#! /bin/sh

DEMO_LIBS="./deps/*/ebin ./ebin"

exec erl -smp enable +stbt db -sname sim -setcookie ship-demo -pa $DEMO_LIBS -run observer
