PROJECT = treehouse
PROJECT_DESCRIPTION = The treehouse spontaneously generates imps, which are used to spawn your resources.
PROJECT_VERSION = 0.0.1
DEPS = cowboy dht chumak luerl gun lager uuid jsx msgpack
dep_cowboy = git https://github.com/ninenines/cowboy 1.1.x
dep_dht = git https://github.com/jlouis/dht.git

include erlang.mk
