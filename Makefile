PROJECT = treehouse
PROJECT_DESCRIPTION = Spontaneous units spawn your computing resources.
PROJECT_VERSION = 0.3.0
DEPS = lager chumak luerl econfig uuid jsx gun
ERLC_OPTS = +debug_info
include erlang.mk
# trying to ident with 4 spaces here.
SP = 4
# Compile flags
ERLC_COMPILE_OPTS= +'{parse_transform, lager_transform}'
# Append these settings
ERLC_OPTS += $(ERLC_COMPILE_OPTS)
TEST_ERLC_OPTS += $(ERLC_COMPILE_OPTS)
