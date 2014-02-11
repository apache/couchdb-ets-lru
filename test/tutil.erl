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

-module(tutil).

-export([
    run/2,
    with_lru/1
]).


run(Plan, Fun) ->
    etap:plan(Plan),
    case (catch Fun()) of
        ok ->
            etap:end_tests();
        Error ->
            Msg = lists:flatten(io_lib:format("Error: ~p", [Error])),
            etap:bail(Msg)
    end.


with_lru(Fun) ->
    {ok, LRU} = ets_lru:start_link(test_lru, []),
    Ref = erlang:monitor(process, LRU),
    try
        Fun(LRU)
    after
        ets_lru:stop(LRU),
        receive {'DOWN', Ref, process, LRU, _} -> ok end
    end.

