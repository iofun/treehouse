#! /bin/sh

DEMO_LIBS="$HOME/work/structures/treehouse/deps/luerl/ebin $HOME/work/structures/treehouse/deps/uuid/ebin $HOME/work/structures/treehouse/deps/chumak/ebin $HOME/work/structures/treehouse/deps/esdl2/ebin ./ebin"

# observer
exec erl -smp enable +stbt db -sname sim -setcookie ship-demo -pa $DEMO_LIBS
