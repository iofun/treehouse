PROJECT = blackboard 
PROJECT_DESCRIPTION = Spawn daemons over time and grow them into other units
PROJECT_VERSION = 0.1.0
DEPS = luerl chumak econfig uuid jsx gun meck
ERLC_OPTS = +debug_info
include erlang.mk
# trying to ident with 4 spaces here.
SP = 4
