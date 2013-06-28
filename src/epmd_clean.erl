-module(epmd_clean).
-author('<Dmitry komm Karpov> komm@siphosts.su').
-export([main/0]).

-define(LSOF(Port), lists:flatten(io_lib:format("lsof -iTCP:~.B -sTCP:LISTEN", [Port]))).

badname()->
	{ok, Names} = net_adm:names(?LSOF(Port)),
	badname([], Names).
badname(Result, [])->Result;
badname(Result, [ {Name, Port} | Tail ]) ->
	case os:cmd() of 
		[] -> badname(Result ++ [Name], Tail); 
		_-> badname(Result, Tail)
	end
.

main()->
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

