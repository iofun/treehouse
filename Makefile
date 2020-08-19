PROJECT = spaceboard 
PROJECT_DESCRIPTION = Spawn daemons over time and grow them into other units
PROJECT_VERSION = 0.1.0
DEPS = luerl cowboy chumak econfig uuid jsx gun meck
dep_cowboy = git https://github.com/ninenines/cowboy 2.8.0
dep_jsx = git https://github.com/talentdeficit/jsx main
ERLC_OPTS = +debug_info
include erlang.mk
# trying to ident with 4 spaces here.
SP = 4
