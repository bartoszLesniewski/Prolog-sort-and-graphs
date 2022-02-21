% Zadanie 1.
% Sortowanie przez zliczanie (counting sort)

% wyznaczanie długości listy (arg1 - lista, arg2 - wynik)
list_length([], 0).
list_length([_|T], L) :- list_length(T, P), L is P + 1.

% tworzenie nowej listy wypełnionej podaną wartością (arg1 - wartość, arg2 - długość listy, arg3 - wynik)
create_list(_, 0, []).  
create_list(X, N, [X|L]) :-
    N > 0, N1 is N - 1,
    create_list(X, N1, L).

% pobieranie n-tego elementu listy (arg1 - lista, arg2 - indeks elementu, który należy pobrać, arg3 - wynik)
get_nth_element([H|_], 0, H).
get_nth_element([_|T], N, E) :- N1 is N - 1, get_nth_element(T, N1, E).

% zamiana podanego elementu listy na inną wartość
% (arg1 - lista wejściowa, arg2 - indeks elementu, który ma zostać zamieniony, arg3 - wartość na jaką zamienić, arg4 - wynik)
replace_element([_|T], 0, V, [V|T]).
replace_element([H|T], P, E, [H|R]) :- NP is P - 1, replace_element(T, NP, E, R).

% zliczanie ilości wystąpień poszczególnych elementów listy
% (arg1 - lista z wartościami, arg2 - lista z licznikami, arg3 - wynik)
count([], Cnt_list, Cnt_list).
count([X|Y], Cnt_list, Out_list) :- 
    get_nth_element(Cnt_list, X, E), 
    E1 is E + 1,
    replace_element(Cnt_list, X, E1, New_cnt_list),  
    count(Y, New_cnt_list, Out_list).

% wyznaczenie dla każdego elementu, ile jest elementów większych lub równych
% (arg1 - lista z licznikami, arg2 - index rozpatrywanego elementu (zaczynamy od przedostatniego), arg3 - wynik)
sum_counters(Cnt_list, -1, Cnt_list).
sum_counters(Cnt_list, N, Out_list) :-
    N1 is N + 1,
    get_nth_element(Cnt_list, N1, E1),
    get_nth_element(Cnt_list, N, E2), 
    Sum is E1 + E2,
    replace_element(Cnt_list, N, Sum, New_cnt_list),
    N2 is N - 1,
    sum_counters(New_cnt_list, N2, Out_list).

% dodwanie elementu do listy na podanej pozycji
% (arg1 - wartość, arg2 - pozycja, arg3 - lista, arg4 - wynik)
insert_element(V, 0, [_|T], [V|T]).
insert_element(V, P, [H|T], [H|R]) :- P1 is P - 1, !, insert_element(V, P1, T, R).

% tworzenie posortowanej listy
% (arg1 - indeks elementu z listy wejściowej, arg2 - lista wejściowa, arg3 - lista z licznikami, 
% arg4 - pusta lista, którą wypełniamy posortowanymi elementami, arg5 - wynik)
create_sorted_list(-1, _, _, Empty_list, Empty_list).
create_sorted_list(Index, List, Cnt_list, Empty_list, Sorted_list) :- 
    get_nth_element(List, Index, E),
    get_nth_element(Cnt_list, E, P),
    Index1 is Index - 1,
    NewPos is P - 1,
    insert_element(E, NewPos, Empty_list, Semi_sorted),

    replace_element(Cnt_list, E, NewPos, New_cnt_list),
    create_sorted_list(Index1, List, New_cnt_list, Semi_sorted, Sorted_list).

% główna funckcja sortująca
sortuj(Lista, Posortowana) :-
    Max is 101,
    list_length(Lista, Length),
    create_list(x, Length, Sorted_list),
    create_list(0, Max, Cnt_start_list),
    count(Lista, Cnt_start_list, Cnt_list),
    M is Max - 2,
    sum_counters(Cnt_list, M, Cnt_sum_list),
    Index is Length - 1,
    create_sorted_list(Index, Lista, Cnt_sum_list, Sorted_list, Posortowana), !.


% Zadanie 2
% Czy lista tworzy ciąg graficzny?
% Havel-Hakimi algorithm (Largest-First)
% 1. Jeśli wszystkie wyrazy ciągu są równe 0, to ciąg jest graficzny.
% 2. Jeśli któryś z elementów ciągu jest < 0, to ciąg nie jest graficzny.
% 3. Uporządkuj ciąg nierosnąco według stopni.
% 4. Odejmij 1 od d_1 elementów ciągu począwszy od elementu d_2, a pod d_1 podstaw 0.
% 5. Wróc do kroku 1.

% sprawdzenie czy lista jest pusta lub wypełniona samymi zerami
is_empty([]).
is_empty([0]).
is_empty([H|T]) :- H == 0, is_empty(T), !.

% zmniejszanie kolejnych n elementów o 1
substract(List, 0, List).
substract([H|T], N, [H1|T1]) :- H1 is H - 1, N1 is N - 1, substract(T, N1, T1).

% sprawdzenie, czy lista zawiera tylko nieujemne wartości
check_if_non_negative([]).
check_if_non_negative([H|T]) :- H >= 0, check_if_non_negative(T).

% stworzenie nowego ciągu (po zmniejszeniu elementów)
make_new_sequence([H|T], [H1|T1]) :- list_length(T, Length), Length >= H, substract(T, H, T1), H1 is 0.

% sprawdzenie, czy ciąg jest graficzny
czy_graficzny(Ciag) :-
    is_empty(Ciag), !;
    sortuj(Ciag, Sorted),
    make_new_sequence(Sorted, New_sequence), !,
    check_if_non_negative(New_sequence), !,
    czy_graficzny(New_sequence).

% zwrócenie odpowiedzi, czy ciąg jest graficzny
czy_graficzny(Ciag, Odp) :- czy_graficzny(Ciag), Odp = "Ciag jest graficzny", !.
czy_graficzny(_, Odp) :- Odp = "Ciag NIE JEST graficzny".


% Zadanie 3
% Czy lista stopni wierzchołków tworzy ciąg graficzny, z którego powstanie graf spójny
% Havel-Hakimi algorithm (Smallest-First)

% obliczenie sumy stopni z listy
sum_of_degrees([], 0).
sum_of_degrees([H|T], Sum) :- H >= 1, sum_of_degrees(T, S1), Sum is S1 + H.

% sprawdzenie, czy graf jest potencjalnie spójny
% graf jest potencjalnie spójny <=> każdy ze stopni jest >= 1 oraz suma stopni >= 2*(dlugosc_ciagu - 1)
potentially_connected([H|T]) :- sum_of_degrees([H|T], Sum), list_length([H|T], Length), Sum >= 2*(Length - 1).

% pobranie ostatniego elementu z ciągu
last_element([H], H).
last_element([_|T], X) :- last_element(T, X).

% usunięcie ostatniego elementu z ciągu
cut_last([_], []).
cut_last([H|T], [H|T1]) :- cut_last(T, T1).

% stworzenie nowego ciągu (po zmniejszeniu elementów)
make_new_sequence_SF([H|T], New) :- 
last_element([H|T], Last), 
list_length(T, Length), 
Length >= Last, 
cut_last([H|T], Without_last),
substract(Without_last, Last, New).

% sprawdzenie czy powstanie graf spójny
czy_spojny(Ciag) :- 
    is_empty(Ciag), !;
    sortuj(Ciag, Sorted),
    make_new_sequence_SF(Sorted, New_sequence), !,
    check_if_non_negative(New_sequence), !,
    czy_spojny(New_sequence).

% zwrócenie odpowiedzi, czy powstanie graf spójny
czy_spojny(Ciag, Odp) :- 
(not(czy_graficzny(Ciag)); not(potentially_connected(Ciag)); not(czy_spojny(Ciag))), 
Odp = "Z ciagu NIE POWSTANIE graf spojny", !.
czy_spojny(_, Odp) :- Odp = "Z ciagu powstanie graf spojny"


