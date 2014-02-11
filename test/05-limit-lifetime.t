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

lifetime() -> 100.

main([]) ->
    code:add_pathz("test"),
    code:add_pathz("ebin"),

    tutil:run(2, fun() -> test() end).


test() ->
    {ok, LRU} = ets_lru:start_link(lru, [{max_lifetime, lifetime()}]),
    ok = test_single_entry(LRU),
    ok = ets_lru:stop(LRU).


test_single_entry(LRU) ->
    ets_lru:insert(LRU, foo, bar),
    etap:is(ets_lru:lookup(LRU, foo), {ok, bar}, "Expire leaves new entries"),
    timer:sleep(round(lifetime() * 1.5)),
    etap:is(ets_lru:lookup(LRU, foo), not_found, "Entry was expired"),
    ok.
