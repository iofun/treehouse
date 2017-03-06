PROJECT = treehouse
PROJECT_DESCRIPTION = Spontaneously generates imps used to spawn your resources.
PROJECT_VERSION = 0.0.1
DEPS = econfig cowboy hackney dht chumak luerl lager uuid jiffy msgpack
dep_cowboy = git https://github.com/ninenines/cowboy 1.1.x
dep_dht = git https://github.com/jlouis/dht.git

# this must be first
include erlang.mk

# Compile flags
ERLC_COMPILE_OPTS= +'{parse_transform, lager_transform}'

# Append these settings
ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERLC_OPTS += $(ERLC_COMPILE_OPTS)