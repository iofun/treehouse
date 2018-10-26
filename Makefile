PROJECT = daemons 
PROJECT_DESCRIPTION = Spawn more water daemons! 
PROJECT_VERSION = 0.8.0
DEPS = luerl chumak econfig uuid jsx gun meck
ERLC_OPTS = +debug_info
include erlang.mk
# trying to ident with 4 spaces here.
SP = 4
