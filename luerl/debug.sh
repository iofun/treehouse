#! /bin/sh

DEMO_LIBS="../deps/*/ebin ../ebin"

exec erl -smp enable +stbt db -sname simdemo -setcookie simdemo -pa $DEMO_LIBS
