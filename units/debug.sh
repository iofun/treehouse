#! /bin/sh

DEMO_LIBS="../deps/*/ebin ../ebin"

exec erl -smp enable +stbt db -sname sim -setcookie treehouse -pa $DEMO_LIBS
