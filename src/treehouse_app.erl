-module(treehouse_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [{"/", hello_handler, []}]}
	]),
	{ok, _} = cowboy:start_clear(http_listener, 100,
			[{port, 8888}],
			#{env => #{dispatch => Dispatch}}
	),
	treehouse_sup:start_link().

stop(_State) ->
	ok.
