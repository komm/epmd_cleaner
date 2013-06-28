#!/usr/bin/env escript
%% -*- erlang -*-

badname()->
	{ok, Names} = net_adm:names(),
	badname([], Names).
badname(Result, [])->Result;
badname(Result, [ {Name, Port} | Tail ]) ->
	case os:cmd(lists:flatten(io_lib:format("lsof -iTCP:~.B -sTCP:LISTEN", [Port]))) of 
		[] -> badname(Result ++ [Name], Tail); 
		_-> badname(Result, Tail)
	end
.

main(["epmd_clean"])->
	BadNames=badname(),
	io:format('BadNames: ~p~n~n', [BadNames]),
	[
		fun(X)->
			{ok, Socket} = gen_tcp:connect("localhost", 4369, [binary]),
			Length = length(X)+1,
			gen_tcp:send(Socket,[[0, Length], $s, X]),
			gen_tcp:close(Socket)
		end(Name)
	        || Name <- BadNames
	]
.

