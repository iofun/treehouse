-module(treehouse_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    application:ensure_all_started(econfig),
    econfig:register_config(spawn, ["/etc/spawn.conf"], [autoreload]),
    econfig:subscribe(spawn),
    Lol = econfig:get_value(spawn, "engine"),
    lager:warning("Yo spawn in here ~p \n", [Lol]),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/units/", units_handler, []},
            {"/schemes/", schemes_handler, []},
            {"/structures/", structures_handler, []}  
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, 8215}],
        #{env => #{dispatch => Dispatch}}
    ),
    {ok, _} = sub_bind:start_link(),
    treehouse_sup:start_link().

stop(_State) ->
    ok.