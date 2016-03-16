%                           ---UTILITY FUNCTIONS---
% ------------------------------------------------------------------------------
% Appends one list to another
% ?- app([1,2,3], [4,5,6], X).
% X = [1, 2, 3, 4, 5, 6].
app([],L,L).
app([H|T],A,[H|B]) :- app(T,A,B).


% Builds a list of numbers between Start and End parameter
% ?- numlist(2, 8, X).
% X = [2, 3, 4, 5, 6, 7, 8] ;
numlist(X,X,[X]) :- !.
numlist(Start,End,[Start|Result]) :-
    Start =< End,
    Next is Start+1,
    numlist(Next, End, Result).

% Returns true if element is a member of passed list
% ?- is_member(1, [3,6,7,1]).
% true.
is_member(X, [Y|T]) :- X = Y, !; is_member(X, T).

% Returns true if product can be found in list of quadruple pairs
% ?- check_dup_product(1, [[3,6,7,2], [4,6,4,1], [8,5,2,2]]).
% true.
check_dup_product(X, [[_,_,_,H]|T]) :-
    X = H, !;
    check_dup_product(X, T).

% Returns true if product can be found in list of quadruple pairs
% ?- check_dup_sum(1, [[3,6,7,2], [4,6,4,1], [8,5,2,2]]).
% true.
check_dup_sum(X, [[_,_,H,_]|T]) :-
    X = H, !;
    check_dup_sum(X, T).

% ?- remove_sums([[1,2,3,4],[5,6,7,8],[9,0,1,2]], [3,1], X).
% X = [[5, 6, 7, 8]].
remove_sums([], _, []) :- !.
remove_sums([H|T], Y, Res) :-
    nth0(2, H, Prod),
    is_member(Prod, Y), !,
    remove_sums(T, Y, Res).
remove_sums([H|T], Y, [H|Res]) :-
    remove_sums(T, Y, Res).


%                       ---QUADRUPLE BUILDING FUNCTIONS---
% ------------------------------------------------------------------------------
% Takes two lists as input, returns cross product of all quadruple combinations
% Example usage:
% ?- map_values([1,2], [3,4], X).
% X = [[1, 3, 4, 3], [1, 4, 5, 4], [2, 3, 5, 6], [2, 4, 6, 8]]
map_values([],_,[]).
map_values([H|T],Y,Result) :-
    make_quads(H,Y,QuadruplePairs),
    map_values(T,Y,Row),
    app(QuadruplePairs,Row,Result),!.

% Constructs a list of quadruples for a given number
% ?- make_quads(29, [30, 31, 32, 33], X).
% X = [[29, 30, 59, 870], [29, 31, 60, 899], [29, 32, 61, 928], [29, 33, 62, 957]]
make_quads(_,[],[]) :- !.
make_quads(X, [Y|T], Result) :-
    % Prevent program from proceeding if X > Y
    X >= Y, !,
    Result = R,
    make_quads(X, T, R).
make_quads(X, [Y|T], Result) :-
    % Prevent program from proceeding if X + Y >= 100
    X+Y > 100, !,
    Result = R, make_quads(X, T, R).
make_quads(X, [Y|T], Result) :-
    Product is X * Y,
    Sum is X + Y,
    Result = [[X,Y,Sum,Product]|R],
    make_quads(X, T, R).

%                               ---SORTING FUNCTIONS---
% ------------------------------------------------------------------------------

% ?- sort_by_product([[1,1,1,5], [1,1,1,4], [1,1,1,3], [1,1,1,2], [1,1,1,1]], X).
% X = [[1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 1, 3], [1, 1, 1, 4], [1, 1, 1, 5]] ;
sort_by_product([],[]).
sort_by_product([A],[A]).
sort_by_product([A,B|R],S) :-
   split([A,B|R],L1,L2),
   sort_by_product(L1,S1),
   sort_by_product(L2,S2),
   merge_splits(S1,S2,S).
% Splits a merge
split([],[],[]).
split([A],[A],[]).
split([A,B|R],[A|Ra],[B|Rb]) :-  split(R,Ra,Rb).
% Merge together two splits
merge_splits(A,[],A).
merge_splits([],B,B):- B\=[].
merge_splits([[X1,Y1,Sum1,A]|Ra],[[X2,Y2,Sum2,B]|Rb],[[X1,Y1,Sum1,A]|M]) :-
    A =< B,
    merge_splits(Ra,[[X2,Y2,Sum2,B]|Rb],M).
merge_splits([[X1,Y1,Sum1,A]|Ra],[[X2,Y2,Sum2,B]|Rb],[[X2,Y2,Sum2,B]|M]) :-
    A > B,
    merge_splits([[X1,Y1,Sum1,A]|Ra],Rb,M).


%                   ---REMOVE UNIQUE PRODUCTS FUNCTIONS---
% ------------------------------------------------------------------------------
% Takes list of quadruples and removes any quadruples with a unique product
% ?- duplicate_products([[1,1,1,4],[2,2,2,4],[3,3,3,4],[5,5,5,5]], X).
% X = [[1, 1, 1, 4], [2, 2, 2, 4], [3, 3, 3, 4]].
duplicate_products(X, Res) :-
    duplicate_products(X, [], Res).

% Passing an empty list of products will return an empty list
duplicate_products([], _, []) :- !.
duplicate_products([H|T], Sort, Res) :-
    % Don't proceed if the current product is already in sorted
    nth0(3, H, A),
    is_member(A, Sort), !,
    Res = [H|NRes],
    duplicate_products(T, Sort, NRes).

duplicate_products([H|T], Sort, Res) :-
    % Don't proceed if the current product can't be found in the rest of the list
    nth0(3, H, A),
    check_dup_product(A, T), !,
    % Update the results and sorted lists
    Res = [H|NRes],
    duplicate_products(T, [A|Sort], NRes).

duplicate_products([_|T], Sort, Res) :-
    % If no duplicate products can be found then the result stays the same
    duplicate_products(T, Sort, Res).


%                   ---REMOVE DUPLICATE LIST ELEMENTS ---
% ------------------------------------------------------------------------------

% ?- unique_products([[1,3,7,6],[9,2,4,8],[5,8,3,1],[9,2,4,3]], X).
% X = [7, 4, 3, 4].
unique_products(X, Res) :-
    unique_products(X, [], Res).

% Passing an empty list of products will return an empty list
unique_products([], _, []) :- !.

unique_products([H|T], Sort, Res) :-
    % Get the Product form the head and check if it's in sorted
    nth0(3, H, A),
    is_member(A, Sort), !,
    % Sort and Res stays the same
    unique_products(T, Sort, Res).

unique_products([H|T], Sort, Res) :-
    % Don't proceed if the product appears in the rest of the list
    nth0(3, H, A),
    check_dup_product(A, T), !,
    unique_products(T, [A|Sort], Res).

unique_products([H|T], Sort, Res) :-
    % If no duplicate products can be found then update results
    Res = [H|NRes],
    unique_products(T, Sort, NRes).



% ?- unique_sums([[1,3,7,6],[9,2,7,8],[5,8,7,1],[9,2,4,3]], X).
% X = [[9, 2, 4, 3]].
unique_sums(X, Res) :-
    unique_sums(X, [], Res).

% Passing an empty list of products will return an empty list
unique_sums([], _, []) :- !.

unique_sums([H|T], Sort, Res) :-
    % Get the Product form the head and check if it's in sorted
    nth0(2, H, A),
    is_member(A, Sort), !,
    % Sort and Res stays the same
    unique_sums(T, Sort, Res).

unique_sums([H|T], Sort, Res) :-
    % Don't proceed if the product appears in the rest of the list
    nth0(2, H, A),
    check_dup_sum(A, T), !,
    unique_sums(T, [A|Sort], Res).

unique_sums([H|T], Sort, Res) :-
    % If no duplicate products can be found then update results
    Res = [H|NRes],
    unique_sums(T, Sort, NRes).


%               ---COLLECT SUMS CORRESPONDING TO UNIQUE PRODUCTS---
% ------------------------------------------------------------------------------
% Return a list of sums corresponding to unique products from a list of quadruples
% ?- sums_to_unique_products([[1,3,7,6],[9,2,4,8],[5,8,3,1],[9,2,4,3]], X).
% X = [7, 4, 3, 4].
sums_to_unique_products(X, Res) :-
    sums_to_unique_products(X, [], Res).

% Passing an empty list of products will return an empty list
sums_to_unique_products([], _, []) :- !.

sums_to_unique_products([H|T], Sort, Res) :-
    % Get the Product form the head and check if it's in sorted
    nth0(3, H, A),
    is_member(A, Sort), !,
    % Sort and Res stays the same
    sums_to_unique_products(T, Sort, Res).

sums_to_unique_products([H|T], Sort, Res) :-
    % Don't proceed if the product appears in the rest of the list
    nth0(3, H, A),
    check_dup_product(A, T), !,
    sums_to_unique_products(T, [A|Sort], Res).

sums_to_unique_products([H|T], Sort, Res) :-
    % If no duplicate products can be found then update results
    nth0(2, H, Prod), Res = [Prod|NRes],
    sums_to_unique_products(T, Sort, NRes).


%                   ---MATHEMATICIANS STATEMENTS---
% ------------------------------------------------------------------------------

% Binds Q to a list of quadruples [X, Y, S, P] where X and Y are possible
% solutions after sentence (a) is pronounced
s1(Q, N) :-
    numlist(2, N, X),
    map_values(X, X, Y),
    sort_by_product(Y, Z),
    duplicate_products(Z, Q),!.

% Binds Q to a list of quadruples [X, Y, S, P] where X and Y are possible
% solutions after sentence (b) is pronounced
s2(Q, N) :-
    s1(S1Result, N),
    numlist(2, N, X), map_values(X, X, Y), 
    sort_by_product(Y, Sorted),
    sums_to_unique_products(Sorted, Unique_Products),
    remove_sums(S1Result, Unique_Products, Q), !.

s3(Q, N) :-
    s2(S2Result, N),
    unique_products(S2Result, Q), !.

s4(Q, N) :-
    s3(S3Result, N),
    unique_sums(S3Result, Q), !.
