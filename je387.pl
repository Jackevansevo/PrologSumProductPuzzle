/*
je387
THIS WORK IS ENTIRELY MY OWN.
The program does does not produce multiple answers.
I have have not used built-ins.

1. s1(Q, 100): 1747

- Creates a list [2,3,4,...,100]
- Maps two copies of the list together e.g.
    loops through 1st list [1,2,3,4,...1000]
    compares each head with tail of 2nd list
    2 -> [3,4,5,...,100]
- Then creates a list of quadruple pairs from these combinations where 1 < X < Y nad X + Y <= N
- Sorts by the product
- Removes duplicate products

2. s2(Q, 100): 145

- Finds all the sums corresponding to unique products, places them in a list
- Sorts the sums and removes duplicates
- Removes occurances of any of these sums from the result in S1

3. s3(Q, 100): 86

- Sorts quadruples by products
- Scans through list, only keeping unique produts (removing duplicates)

4.

- Sorts quadruples by sum
- Scans through list, only keeping unique sums (removing duplicates)

5. s4(Q, 100): 1
s4(Q,500) uses % 217,793 inferences
*/



%                           ---UTILITY FUNCTIONS---
% ------------------------------------------------------------------------------

% Concatenates two lists together
% ?- app([1,2,3],[4,5,6], X).
% X = [1, 2, 3, 4, 5, 6].
app([], L, L).
app([H|T], L, [H|R]) :-
    app(T, L, R).

% Concatenates list of lists (equiv to partial flatten)
% ?- app([[[48,49,97,2352],[48,51,99,2448]],[[49,50,99,2450],[49,51,100,2499]]], X).
% X = [[48, 49, 97, 2352], [48, 51, 99, 2448], [49, 50, 99, 2450], [49, 51, 100, 2499]].
app([], []).
app([L|Ls], As) :-
    app(L, Ws, As),
    app(Ls, Ws).

% Builds a list of numbers between Start and End parameter
% ?- numlist(2, 8, X).
numlist(X, X, List) :- !,
    List = [X].
numlist(Start, End, [Start|Result]) :-
    Next is Start+1,
    numlist(Next, End, Result).

% Returns true if product can be found in list of quadruple pairs
% ?- check_product(12, [[3,4,7,12],[2,6,8,12],[2,7,9,14],[3,5,8,15],[2,8,10,16]]).
% true.
check_product([_,_,_,X], [[_,_,_,X]|_]) :- !.
check_product([_,_,_,X], [[_,_,_,H]|_]) :-
    H > X, !,
    check_product(X, []).

% Returns true if sum can be found in list of quadruple pairs
% ?- check_sum(12, [[3,4,7,12],[2,6,8,12],[2,7,9,14],[3,5,8,15],[2,8,10,16]]).
% true.
check_sum([_,_,X,_], [[_,_,X,_]|_]) :- !.
check_sum([_,_,X,_], [[_,_,H,_]|_]) :-
    H > X, !,
    check_sum(X, []).

% Checks if element is a member of a sorted list
% ?- is_member_of_sorted(28, [28,24,24,20,18,12]).
% true.
is_member_of_sorted(X, [X|_]) :- !.
is_member_of_sorted(X, [H,_]) :-
    H < X, !,
    is_member_of_sorted(X, []).

% Returns true if element is a member of passed list
% ?- is_member(1, [3,6,7,1]).
% true.
is_member(X,[X|_]) :- !.
is_member(X,[_|T]):- is_member(X,T).

% ?- remove_sums([[1,2,3,4],[5,6,7,8],[9,0,1,2]], [3,1], X).
% X = [[5, 6, 7, 8]].
remove_sums([], _, []) :- !.
remove_sums([[_,_,H,_]|T], Y, Res) :-
    is_member(H, Y), !,
    remove_sums(T, Y, Res).
remove_sums([H|T], Y, [H|Res]) :-
    remove_sums(T, Y, Res).


% %                       ---QUADRUPLE BUILDING FUNCTIONS---
% % ------------------------------------------------------------------------------
% % Takes two lists as input, returns cross product of all quadruple combinations
% % Example usage:
% ?- map_values([2,3,4,5], [2,3,4,5], 100, X).
% X = [[[2, 3, 5, 6], [2, 4, 6, 8], [2, 5, 7, 10]], [[3, 4, 7, 12], [3, 5, 8, 15]], [[4, 5, 9, 20]]].
map_values([_],[_],_,[]) :- !.
map_values([H|T], [_|T2], N, Result) :-
    make_quads(H, T2, N, Quads),
    Result = [Quads|R],
    map_values(T, T2, N, R).

% Constructs a list of quadruples for a given number
% ?- make_quads(29, [30, 31, 32, 33], 100, X).
% X = [[29, 30, 59, 870], [29, 31, 60, 899], [29, 32, 61, 928], [29, 33, 62, 957]]
make_quads(_, [], _, []) :- !.
make_quads(X, [X|T], N, Result) :-
    % Prevent program proceeding if X is equal to Y using pattern matching
    make_quads(X, T, N, Result).
make_quads(X, [Y|T], N, Result) :-
    % Prevent program from proceeding if X > Y
    X > Y, !,
    make_quads(X, T, N, Result).
make_quads(X, [Y|T], N, Result) :-
    % Prevent program from proceeding if X + Y >= N
    X+Y > N, !,
    make_quads(X, T, N, Result).
make_quads(X, [Y|T], N, Result) :-
    Product is X * Y, Sum is X + Y,
    Result = [[X,Y,Sum,Product]|R],
    make_quads(X, T, N, R).


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
   merge_splits_product(S1,S2,S).

% Merge together two splits
merge_splits_product(A,[],A).
merge_splits_product([],B,B):- B\=[].
merge_splits_product([[X1,Y1,Sum1,A]|Ra],[[X2,Y2,Sum2,B]|Rb],[[X1,Y1,Sum1,A]|M]) :-
    A =< B, !,
    merge_splits_product(Ra,[[X2,Y2,Sum2,B]|Rb],M).
merge_splits_product([[X1,Y1,Sum1,A]|Ra],[[X2,Y2,Sum2,B]|Rb],[[X2,Y2,Sum2,B]|M]) :-
    merge_splits_product([[X1,Y1,Sum1,A]|Ra],Rb,M).

% ?- sort_by_sum([[1,1,1,5], [1,1,1,4], [1,1,1,3], [1,1,1,2], [1,1,1,1]], X).
% X = [[1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 1, 3], [1, 1, 1, 4], [1, 1, 1, 5]] ;
sort_by_sum([],[]).
sort_by_sum([A],[A]).
sort_by_sum([A,B|R],S) :-
   split([A,B|R],L1,L2),
   sort_by_sum(L1,S1),
   sort_by_sum(L2,S2),
   merge_splits_sums(S1,S2,S).
% Merge together two splits
merge_splits_sums(A,[],A).
merge_splits_sums([],B,B):- B\=[].
merge_splits_sums([[X1,Y1,Sum1,A]|Ra],[[X2,Y2,Sum2,B]|Rb],[[X1,Y1,Sum1,A]|M]) :-
    Sum1 =< Sum2, !,
    merge_splits_sums(Ra,[[X2,Y2,Sum2,B]|Rb],M).
merge_splits_sums([[X1,Y1,Sum1,A]|Ra],[[X2,Y2,Sum2,B]|Rb],[[X2,Y2,Sum2,B]|M]) :-
    merge_splits_sums([[X1,Y1,Sum1,A]|Ra],Rb,M).

% Splits a merge
split([],[],[]):-!.
split([A],[A],[]):-!.
split([A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P|R],[A,B,C,D,E,F,G,H|Ra],[I,J,K,L,M,N,O,P|Rb]) :-  split(R,Ra,Rb),!.
split([A,B,C,D,E,F,G,H|R],[A,B,C,D|Ra],[E,F,G,H|Rb]) :-  split(R,Ra,Rb),!.
split([A,B,C,D|R],[A,B|Ra],[C,D|Rb]) :-  split(R,Ra,Rb),!.
split([A,B|R],[A|Ra],[B|Rb]) :-  split(R,Ra,Rb),!.


% Sorts a list of numbers and removes duplicates along the way
% ?- set_sort([4,4,4,3,3,3,2,2,2,1,1,1,7,7,7,6,6,6,9,9,9], X).
% X = [1, 2, 3, 4, 6, 7, 9].
set_sort([],[]).
set_sort([A],[A]).
set_sort([A,B|R],S) :-
   split([A,B|R],L1,L2),
   set_sort(L1,S1),
   set_sort(L2,S2),
   merge_split(S1,S2,S),!.

% Merge together two splits
merge_split(A,[],A).
merge_split([],B,B):- B\=[].
merge_split([A|Ra],[A|Rb],[A|M]) :-
    !,
    merge_split(Ra,Rb,M).
merge_split([A|Ra],[B|Rb],[A|M]) :-
    A < B, !,
    merge_split(Ra,[B|Rb],M).
merge_split([A|Ra],[B|Rb],[B|M]) :-
    merge_split([A|Ra],Rb,M).


%                   ---UNIQUE/DUPLICATE PRODUCTS FUNCTIONS---
% ------------------------------------------------------------------------------
% ?- duplicate_products([[2,3,5,6],[2,4,6,8],[2,5,7,10],[3,4,7,12],[2,6,8,12]], X).
% X = [[3, 4, 7, 12], [2, 6, 8, 12]].
duplicate_products(X, Res) :-
    duplicate_products(X, [], Res).
duplicate_products([], _, []) :- !.
duplicate_products([H|T], Sort, Res) :-
    % If current product appears again in the tail it's a duplicate, so add it
    % to the Results and update the Sorted list
    check_product(H, T), !,
    Res = [H|NRes],
    duplicate_products(T, [H|Sort], NRes).
duplicate_products([H|T], Sort, Res) :-
    % If the current product can't be found in the tail check if it appears in
    % the sorted list
    check_product(H, Sort), !,
    Res = [H|NRes],
    duplicate_products(T, Sort, NRes).
duplicate_products([_|T], Sort, Res) :-
    % If no duplicate products can be found then the current produt is unique and
    % the results list stays the same
    duplicate_products(T, Sort, Res).


% ?- unique_sums([[4,7,11,28],[3,8,11,24],[4,13,17,52],[4,19,23,76],[10,13,23,130]], X).
% X = [[4, 13, 17, 52]].
unique_sums(X, Res) :-
    unique_sums(X, [], Res).
unique_sums([], _, []) :- !.
unique_sums([H|T], Sort, Res) :-
    % If the current sum appears in the tail then it's not unique
    check_sum(H, T), !,
    unique_sums(T, [H|Sort], Res).
unique_sums([H|T], Sort, Res) :-
    % If the current sum appears in the sorted list then it's not unique
    check_sum(H, Sort), !,
    unique_sums(T, Sort, Res).
unique_sums([H|T], Sort, Res) :-
    % If no duplicate sums can be found then update results
    Res = [H|NRes],
    unique_sums(T, Sort, NRes).


% ?- unique_products([[2,9,11,18],[3,8,11,24],[4,7,11,28],[5,6,11,30],[2,15,17,30],[3,14,17,42],[2,21,23,42]], X).
% X = [[2, 9, 11, 18], [3, 8, 11, 24], [4, 7, 11, 28]].
unique_products(X, Res) :-
    unique_products(X, [], Res).
unique_products([], _, []) :- !.
unique_products([H|T], Sort, Res) :-
    check_product(H, T), !,
    unique_products(T, [H|Sort], Res).
unique_products([H|T], Sort, Res) :-
    check_product(H, Sort), !,
    unique_products(T, Sort, Res).
unique_products([H|T], Sort, Res) :-
    % If no duplicate products can be found then update results
    Res = [H|NRes],
    unique_products(T, Sort, NRes).


%               ---COLLECT SUMS CORRESPONDING TO UNIQUE PRODUCTS---
% ------------------------------------------------------------------------------
% Return a list of sums corresponding to unique products from a list of quadruples
% ?- sums_to_unique_products([[2,3,5,6],[2,4,6,8],[2,5,7,10],[3,4,7,12],[2,6,8,12],[2,7,9,14],[3,5,8,15]], X).
% X = [5, 6, 7, 9, 8].
sums_to_unique_products(X, Res) :-
    sums_to_unique_products(X, [], Res).
sums_to_unique_products([], _, []) :- !.
sums_to_unique_products([H|T], Sort, Res) :-
    % If current product appears again in the tail then it's not unique
    check_product(H, T), !,
    sums_to_unique_products(T, [H|Sort], Res).
sums_to_unique_products([H|T], Sort, Res) :-
    % If current product appears in the sorted list then it's not unique
    check_product(H, Sort), !,
    sums_to_unique_products(T, Sort, Res).
sums_to_unique_products([[_,_,H,_]|T], Sort, Res) :-
    % If current product doesn't appear in the tail or the sorted list then
    % it's a unique element, so add it to results
    Res = [H|NRes],
    sums_to_unique_products(T, Sort, NRes).


%                   ---MATHEMATICIANS STATEMENTS---
% ------------------------------------------------------------------------------

% Binds Q to a list of quadruples [X, Y, S, P] where X and Y are possible
% solutions after sentence (a) is pronounced
s1(Q, N) :-
    numlist(2, N, X),
    map_values(X, X, N, Y),
    app(Y, R),
    sort_by_product(R, Z),
    duplicate_products(Z, Q), !.

% Modified s1 function that returns the original list aswell as the list with only duplicate products
s_1(Q, Z, N) :-
    numlist(2, N, X),
    map_values(X, X, N, Y),
    app(Y, R),
    sort_by_product(R, Z),
    duplicate_products(Z, Q), !.

% Binds Q to a list of quadruples [X, Y, S, P] where X and Y are possible
% solutions after sentence (b) is pronounced
s2(Q, N) :-
    s_1(S1Res, R,  N),
    sums_to_unique_products(R, X),
    set_sort(X, SortedSet),
    remove_sums(S1Res, SortedSet, Q), !.

% Binds Q to a list of quadruples [X, Y, S, P] where X and Y are possible
% solutions after sentence (c) is pronounced
s3(Q, N) :-
    s2(S2Res, N),
    sort_by_product(S2Res, Sorted),
    unique_products(Sorted, Q), !.

% Binds Q to a list of quadruples [X, Y, S, P] where X and Y are possible
% solutions after sentence (d) is pronounced
s4(Q, N) :-
    s3(S3Result, N),
    sort_by_sum(S3Result, Sorted),
    unique_sums(Sorted, Q), !.

% The goal s4(Q,500) will bind Q with a list of quadruples [ X , Y , S , P ] ,
% where S = X + Y and P = XY and X and Y are the solution of the problem above,
% when the constraint on the sum is changed into X + Y
s5(Q, N) :-
    s4(Q, N), !.


/*------------------------------------------------------------------------------
*
* UNABLE TO FIT IN FULL LIST
*
?- consult(test).
true.

?- time(s1(Q, 100)).
% 92,644 inferences, 0.086 CPU in 0.086 seconds (100% CPU, 1071526 Lips)
Q = [[2, 6, 8, 12], [3, 4, 7, 12], [2, 9, 11, 18], [3, 6, 9, 18], [2, 10, 12, 20], [4, 5, 9|...], [3, 8|...], [2|...], [...|...]|...].

?- time(s2(Q, 100)).
% 212,891 inferences, 0.137 CPU in 0.137 seconds (100% CPU, 1556684 Lips)
Q = [[2, 9, 11, 18], [3, 8, 11, 24], [4, 7, 11, 28], [2, 15, 17, 30], [5, 6, 11, 30], [2, 21, 23|...], [3, 14|...], [2|...], [...|...]|...].

*/
