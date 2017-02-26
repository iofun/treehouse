PROJECT = treehouse
PROJECT_DESCRIPTION = The treehouse spontaneously generates imps, which are used to spawn your resources.
PROJECT_VERSION = 0.0.1
DEPS = econfig cowboy hackney dht chumak luerl lager uuid jiffy msgpack esdl2
dep_cowboy = git https://github.com/ninenines/cowboy 1.1.x
dep_dht = git https://github.com/jlouis/dht.git
dep_esdl2 = git https://github.com/ninenines/esdl2.git

# this must be first
include erlang.mk

# Compile flags
ERLC_COMPILE_OPTS= +'{parse_transform, lager_transform}'

# Append these settings
ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERLC_OPTS += $(ERLC_COMPILE_OPTS)