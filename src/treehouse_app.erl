-module(treehouse_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    % Dispatch = cowboy_router:compile([
    %     {'_', [
    %         {"/units/", units_handler, []},
    %         {"/schemes/", schemes_handler, []},
    %         {"/structures/", structures_handler, []}  
    %     ]}
    % ]),
    % {ok, _} = cowboy:start_clear(http, 100, [{port, 8215}], #{
    %     env => #{dispatch => Dispatch}}
    % ),
    {ok, _} = zmq_sub_bind:start_link(),
    treehouse_sup:start_link().

stop(_State) ->
    ok.