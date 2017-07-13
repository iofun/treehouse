PROJECT = treehouse
PROJECT_DESCRIPTION = Spontaneously generate units and spawn your resources.
PROJECT_VERSION = 0.2.0
DEPS = cowboy lager chumak luerl econfig uuid jiffy hackney gun
dep_cowboy_commit = master
DEP_PLUGINS = cowboy
ERLC_OPTS = +debug_info
include erlang.mk
# trying to ident with 4 spaces here.
SP = 4
# Compile flags
ERLC_COMPILE_OPTS= +'{parse_transform, lager_transform}'
# Append these settings
ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERLC_OPTS += $(ERLC_COMPILE_OPTS)