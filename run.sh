#! /bin/sh

DEMO_LIBS="./deps/*/ebin ./ebin"

# -run observer: WX Failed loading "wxe_driver"@"/usr/lib/erlang/lib/wx-1.8/priv"

exec erl -smp enable +stbt db -sname sim -setcookie ship-demo -pa $DEMO_LIBS