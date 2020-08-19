-module(sim_renderer).

-export([start_link/2,start/2]).
-export([init/2]).
-export([get_window/0,get_renderer/0]).
-export([set_tick/1]).

%%-define(WINDOW_NAME, "Universe").		%Older esdl2
%%-define(WINDOW_TITLE, "Universe").
-define(WINDOW_NAME, <<"Universe">>).		%Newer esdl2
-define(WINDOW_TITLE, <<"Universe">>).

-define(DEFAULT_TICK, 20).			%Default render tick

%% Management API.

start(Xsize, Ysize) ->
    proc_lib:start(?MODULE, init, [Xsize,Ysize]).

start_link(Xsize, Ysize) ->
    proc_lib:start_link(?MODULE, init, [Xsize,Ysize]).

%% User API.

set_tick(Tick) ->
    cast({set_tick,Tick}).

get_window() ->
    call(get_window).

get_renderer() ->
    call(get_renderer).

%% Internal protocol functions.

cast(Msg) ->
    sim_renderer ! {cast,self(),Msg},
    ok.

call(Msg) ->
    U = whereis(sim_renderer),
    U ! {call,self(),Msg},
    receive
	{reply,U,Rep} -> Rep
    end.

reply(To, Rep) ->
    To ! {reply,self(),Rep}.

%% Initialise it all.

-record(st, {xsize,ysize,w,r,tab}).

init(Xsize0, Ysize0) ->
    register(sim_renderer, self()),
    %% The actual window size!
    Xsize = 2*Xsize0,
    Ysize = 2*Ysize0,
    ok = sdl:start([video]),
    ok = sdl:stop_on_exit(),
    sdl_keyboard:stop_text_input(),		%Block some messages
    {ok,W} = sdl_window:create(?WINDOW_NAME, 10, 10, Xsize, Ysize,
			       %%[]),
			       [input_focus,mouse_focus]),
			       %%[input_grabbed,input_focus,mouse_focus]),
    ok = sdl_window:set_title(W, ?WINDOW_TITLE),
    ok = sdl_window:show(W),
    {ok,R} = sdl_renderer:create(W, -1, [accelerated,present_vsync]),
    %% Clear screen
    ok = sdl_renderer:set_draw_color(R, 0, 0, 0, 0),
    ok = sdl_renderer:clear(R),
    T = esdl_ship_array,
    Tick = ?DEFAULT_TICK,
    proc_lib:init_ack({ok,self()}),
    erlang:send_after(Tick, self(), render),
    loop(#st{xsize=Xsize,ysize=Ysize,w=W,r=R,tab=T}, Tick).

%% animation loop
loop(St, Tick) ->
    events_loop(),
    receive
	render ->
	    erlang:send_after(Tick, self(), render),
	    render(St),
	    loop(St, Tick);
	{cast,_From,{set_tick,NewTick}} ->
	    loop(St, NewTick);
	{call,From,get_window} ->
	    reply(From, St#st.w),
	    loop(St, Tick);
	{call,From,get_renderer} ->
	    reply(From, St#st.r),
	    loop(St, Tick)
    end.

render(#st{r=Ren,tab=Tab}=St) ->
    ok = sdl_renderer:set_draw_color(Ren, 0, 0, 0, 0),
    ok = sdl_renderer:clear(Ren),
    %% Draw the ships.
    %% We don't need the Acc here, but there is no foreach.
    Draw = fun ({_,null,_,_}, Acc) -> Acc;
	       ({S,Style,Col,Sec}, Acc) ->
		   draw_ship(S, Style, Col, Sec, St),
		   Acc
	   end,
    ets:foldl(Draw, null, Tab),
    ok = sdl_renderer:present(Ren).

draw_ship(_Ship, explosion, _, {X,Y},#st{xsize=Xsize,ysize=Ysize,r=Ren}) ->
    Sx = limit(2*X, 3, Xsize-6),		%Shift point to fit
    Sy = limit(2*Y, 3, Ysize-6),
    R1 = #{x=>Sx,y=>Sy,w=>2,h=>2},
    R2 = #{x=>Sx-1,y=>Sy-1,w=>4,h=>4},
    R3 = #{x=>Sx-2,y=>Sy-2,w=>6,h=>6},
    sdl_renderer:set_draw_color(Ren, 255, 192, 203, 255),
    sdl_renderer:draw_rect(Ren, R3),
    sdl_renderer:set_draw_color(Ren, 255, 255, 0, 255),
    sdl_renderer:draw_rects(Ren, [R1,R2]);
draw_ship(_Ship, _Style, {R,G,B}, {X,Y},#st{xsize=Xsize,ysize=Ysize,r=Ren}) ->
    Sx = limit(2*X, 0, Xsize-1),		%Shift point to fit
    Sy = limit(2*Y, 0, Ysize-1),
    sdl_renderer:set_draw_color(Ren, R, G, B, 255),
    %%S = [#{x=>Sx,y=>Sy},#{x=>Sx,y=>Sy+1},#{x=>Sx+1,y=>Sy},#{x=>Sx+1,y=>Sy+1}],
    %%sdl_renderer:draw_points(Ren, S).
    S = #{x=>Sx-1,y=>Sy-1,w=>4,h=>4},
    sdl_renderer:draw_rect(Ren, S).

%% Check for termination
events_loop() ->
    case sdl_events:poll() of
	false -> ok;
	#{type:=quit} -> terminate();
	Event ->
	    io:format("esdl: ~w\n", [Event]),
	    events_loop()
    end.

terminate() ->
    sdl:stop(),
    init:stop().

limit(I, Min, Max) ->
    if I < Min -> Min;
       I > Max -> Max;
       true -> I
    end.
