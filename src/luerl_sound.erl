-module(luerl_sound).

%% The basic entry point to set up the function table.
-export([install/1]).

-import(luerl_lib, [lua_error/2,badarg_error/3]). %Shorten these

%% This works if luerl/ebin has been added to the path
-include_lib("luerl/src/luerl.hrl").

install(St) ->
    luerl_emul:alloc_table(table(), St).

%% table() -> [{FuncName,Function}].
%% Caller will convert this list to the correct format.

table() ->
    [{<<"make_sound">>,#erl_func{code=fun make_sound/2}}
    ].

make_sound([Sound|_], St) ->
    sim_sound:make_sound(Sound),
    {[],St};
make_sound(As, St) -> badarg_error(make_sound, As, St).
