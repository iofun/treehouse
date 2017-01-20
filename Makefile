# this must be first
include erlang.mk

PROJECT = treehouse
PROJECT_DESCRIPTION = The treehouse spontaneously generates imps, which are used to spawn your resources.
PROJECT_VERSION = 0.0.1
DEPS = cowboy dht chumak luerl gun lager uuid jsx msgpack
dep_cowboy = git https://github.com/ninenines/cowboy 1.1.x
dep_dht = git https://github.com/jlouis/dht.git

# Compile flags
ERLC_COMPILE_OPTS= +'{parse_transform, lager_transform}'

# Append these settings
ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERLC_OPTS += $(ERLC_COMPILE_OPTS)