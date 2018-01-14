PROJECT = treehouse
PROJECT_DESCRIPTION = Spontaneous units spawn your computing resources.
PROJECT_VERSION = 0.2.0
DEPS = lager chumak luerl econfig uuid jiffy hackney
ERLC_OPTS = +debug_info
BUILD_DEPS = lfe lfe.mk
dep_lfe.mk = git https://github.com/ninenines/lfe.mk master
DEP_PLUGINS = lfe.mk
include erlang.mk
# trying to ident with 4 spaces here.
SP = 4
# Compile flags
ERLC_COMPILE_OPTS= +'{parse_transform, lager_transform}'
# Append these settings
ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERLC_OPTS += $(ERLC_COMPILE_OPTS)
