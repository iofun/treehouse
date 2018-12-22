#! /bin/sh

DEMO_LIBS="../deps/*/ebin ../ebin"

exec erl -smp enable +stbt db -sname daemons -setcookie daemons -pa $DEMO_LIBS
