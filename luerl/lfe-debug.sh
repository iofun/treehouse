#! /bin/sh

##DEMO_LIBS="$HOME/luerl/luerl/ebin $HOME/erlang/esdl2-henning/ebin ./ebin"
DEMO_LIBS="$HOME/luerl/luerl/ebin $HOME/erlang/esdl2/ebin ./ebin"

exec lfe -smp enable +stbt db -sname sim -setcookie ship-demo -pa $DEMO_LIBS
