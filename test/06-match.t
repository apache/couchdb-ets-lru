#!/usr/bin/env escript

-define(WITH_LRU(F), tutil:with_lru(fun(LRU) -> F(LRU) end)).

main([]) ->
    code:add_pathz("test"),
    code:add_pathz("ebin"),
    tutil:run(6, fun() -> test() end).

test() ->
    ?WITH_LRU(test_match_zero_values),
    ?WITH_LRU(test_match_one_value),
    ?WITH_LRU(test_match_many_values),
    ?WITH_LRU(test_match_zero_objects),
    ?WITH_LRU(test_match_one_object),
    ?WITH_LRU(test_match_many_objects),
    ok.

test_match_zero_values(LRU) ->
    etap:is(ets_lru:match(LRU, a, '$1'), [], "Empty match").

test_match_one_value(LRU) ->
    ets_lru:insert(LRU, b, {x,y}),
    Values = ets_lru:match(LRU, b, {'$1', '$2'}),
    etap:is(Values, [[x,y]], "Single match").

test_match_many_values(LRU) ->
    ets_lru:insert(LRU, boston, {state, "MA"}),
    ets_lru:insert(LRU, new_york, {state, "NY"}),
    Values = ets_lru:match(LRU, '_', {state, '$1'}),
    etap:is(lists:sort(Values), [["MA"],["NY"]], "Multiple match").

test_match_zero_objects(LRU) ->
    etap:is(ets_lru:match_object(LRU, a, '$1'), [], "Empty match_object").

test_match_one_object(LRU) ->
    ets_lru:insert(LRU, ans, 42),
    etap:is(ets_lru:match_object(LRU, ans, '$1'), [42], "Single match_object").

test_match_many_objects(LRU) ->
    ets_lru:insert(LRU, {color, blue}, a),
    ets_lru:insert(LRU, {color, red}, b),
    Values = ets_lru:match_object(LRU, {color, '_'}, '_'),
    etap:is(lists:sort(Values), [a, b], "Multiple match_object").
