%%--------------------------------------------------------------------
%% Copyright (c) 2019 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

-module(ekka_cluster_dns).

-behaviour(ekka_cluster_strategy).

%% Cluster strategy callbacks
-export([ discover/1
        , lock/1
        , unlock/1
        , register/1
        , unregister/1
        ]).

discover(Options) ->
    DomainName = proplists:get_value(name, Options),
    NodeName = proplists:get_value(app, Options, undefined),
    Type = proplists:get_value(type, Options, a),
    {ok, [node_name(NodeName, Host) || Host <- resolve_hosts(DomainName, Type)]}.

resolve_hosts(DomainName, a) ->
    [inet:ntoa(IP) || IP <- inet_res:lookup(DomainName, in, a)];
resolve_hosts(DomainName, srv) ->
    Records = inet_res:lookup(DomainName, in, srv),
    lists:usort(lists:map(fun({_, _, _, Host}) -> Host end, Records)).

node_name(undefined, Host) ->
    [Name | _] = string:tokens(atom_to_list(node()), "@"),
    node_name(Name, Host);
node_name(NodeName, Host) ->
    list_to_atom(lists:concat([NodeName, "@", Host])).

lock(_Options) ->
    ignore.

unlock(_Options) ->
    ignore.

register(_Options) ->
    ignore.

unregister(_Options) ->
    ignore.
