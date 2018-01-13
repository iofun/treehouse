-module(treehouse_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    application:ensure_all_started(econfig),
    application:ensure_all_started(chumak),
    econfig:register_config(hypercube, ["/etc/tesseract.conf"], [autoreload]),
    econfig:subscribe(hypercube),
    %% SUB BIND, SUB BIND, SUB BIND
    {ok, _} = sub_bind:start_link(),
    treehouse_sup:start_link().

stop(_State) ->
    ok.