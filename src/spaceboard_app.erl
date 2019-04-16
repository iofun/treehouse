-module(blackboard_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    application:ensure_all_started(econfig),
    econfig:register_config(engine, ["../blackboard.conf"], [autoreload]),
    econfig:subscribe(engine),
    blackboard_sup:start_link().

stop(_State) ->
    ok.
