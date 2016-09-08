#!/usr/bin/env escript

main(_) ->
	io:format("Hello escript.\n",[]),
	Si = list_to_binary([<<"asterisk ">>, <<"corazon">>, <<"melon">>]),
	io:format("~p\n",[Si]),
	erlang:halt(0).