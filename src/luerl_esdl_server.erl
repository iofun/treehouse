-module(luerl_esdl_server).

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
    [{<<"add_ship">>,#erl_func{code=fun add_ship/2}},
     {<<"del_ship">>,#erl_func{code=fun del_ship/2}},
     {<<"set_ship">>,#erl_func{code=fun set_ship/2}}
    ].

add_ship([], St) ->
    esdl_server:add_ship(),
    {[],St};
add_ship(As, St) -> badarg_error(add_ship, As, St).

del_ship([], St) ->
    esdl_server:del_ship(),
    {[],St};
del_ship(As, St) -> badarg_error(del_ship, As, St).

%% set_ship([Style,Colour,X,Y|_], State) -> {[],State}.

set_ship([S,C,X,Y], St) when is_number(X), is_number(Y) ->
    %% Convert coulour names to RGB.
    Colour = case C of
		 %% Colourless colours
		 <<"white">> -> {255,255,255};
		 <<"grey">> -> {190,190,190};
		 <<"black">> -> {0,0,0};
		 %% Seven colours of the rainbow
		 <<"red">> -> {255,0,0};
		 <<"orange">> -> {255,165,0};
		 <<"yellow">> -> {255,255,0};
		 <<"green">> -> {0,255,0};
		 <<"blue">> -> {0,0,255};
		 <<"indigo">> -> {75,0,130};
		 <<"violet">> -> {127,0,255};
		 %% Some extras
		 <<"buff">> -> {240,220,130};
		 <<"brown">> -> {150,75,0};
		 <<"cyan">> -> {0,255,255};
		 <<"pink">> -> {255,192,203};
		 <<"mix">> -> {190,190,190};	%Grey
		 _ -> {255,255,255}		%Default colour white
	     end,
    %% Convert style names to atoms.
    Style = ship_style(S),
    esdl_server:set_ship(Style, Colour, X, Y),
    {[],St};
set_ship(As, St) ->
    case luerl_lib:conv_list(As, [lua_string,integer,integer,integer,
				  integer,integer]) of
	[S,R,G,B,X,Y] ->
	    Style = ship_style(S),
	    esdl_server:set_ship(Style, {R,G,B}, X, Y);
	_ -> badarg_error(set_ship, As, St)
    end.

ship_style(<<"extra">>) -> extra;
ship_style(<<"ship">>) -> ship;
ship_style(<<"explosion">>) -> explosion;
ship_style(_) -> ship.				%The default
