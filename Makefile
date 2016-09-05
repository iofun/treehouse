PROJECT = treehouse
PROJECT_DESCRIPTION = The treehouse spontaneously generates imps, which are used to spawn your resources.
PROJECT_VERSION = 0.0.1
DEPS = cowboy chumak luerl gun lager dht msgpack uuid
dep_dht = git https://github.com/jlouis/dht.git
include erlang.mk