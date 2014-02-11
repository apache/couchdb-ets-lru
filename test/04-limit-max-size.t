#! /usr/bin/env escript
% Licensed under the Apache License, Version 2.0 (the "License"); you may not
% use this file except in compliance with the License. You may obtain a copy of
% the License at
%
%   http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
% License for the specific language governing permissions and limitations under
% the License.

max_size() -> 1024.

main([]) ->
    code:add_pathz("test"),
    code:add_pathz("ebin"),

    tutil:run(1, fun() -> test() end).


test() ->
    {ok, LRU} = ets_lru:start_link(lru, [{max_size, max_size()}]),
    etap:is(insert_kvs(LRU, 10000), ok, "Max size ok"),
    ok = ets_lru:stop(LRU).


insert_kvs(LRU, 0) ->
    ok;
insert_kvs(LRU, Count) ->
    ets_lru:insert(LRU, Count, 1.5234),
    case ets:info(lru_objects, memory) > max_size() of
        true -> erlang:error(exceeded_max_size);
        false -> ok
    end,
    insert_kvs(LRU, Count-1).
