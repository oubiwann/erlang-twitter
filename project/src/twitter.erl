%% Author: Jean-Lou Dupont
%% Created: 2009-08-03
%% Description: TODO: Add description to twitter
-module(twitter).

%%
%% Include files
%%
-include("twitter.hrl").

%%
%% Exported Functions
%%
-export([
		 start/0,
		 start_link/0,
		 start_link/1,
		 
		 stop/0
		 ]).

-export([
		 loop/1,
		 rpc/1
		]).

-export([
		 update_status/3
		 ]).

%%
%% API Functions
%%
start() ->
	start_link([]).

start_link() ->
	start_link([]).

stop() ->
	?MODULE ! stop.

%%
%% RPC functions
%%
ping() ->
	rpc(ping).


update_status(Username, Password, Status) ->
	rpc({update_status, Username, Password, Status}).


rpc(Q) ->
	%%io:format("twitteradmin: rpc(~p)~n", [Q]),
	twitter ! {self(), Q},
	receive
		{twitter, Reply} ->
			Reply;
	
		Other ->
			error_logger:error_msg("~p rpc: received [~p]~n", [?MODULE, Other])
	
	after 2000 ->
			rpcerror

	end.


%%
%% Local Functions
%%
start_link(Args) ->
	
	Pid = spawn_link(?MODULE, loop, [Args]),
	register(?MODULE, Pid),
	io:format("~p daemon started, pid[~p]~n", [?MODULE, Pid]),
	inets:start(),
	{ok, Pid}.



loop(Args) ->
	receive
		stop ->
			exit(ok);
	
		{From, ping} ->
			From ! {twitter, {pong, self()}};
		
		{From, {update_status, Username, Password, Status}} ->
			twitter_api:update_status({From, Return}, Username, Password, Status)
	
	end,
	loop(Args).

