% Load model, initial state and formula from file.
verify(Input) :-
    see(Input), read(Transitions), read(Labels), read(CurrentState), read(Formula), seen,
    check(Transitions, Labels, CurrentState, [], Formula).

% Should evaluate to true if the sequent below is valid. %
%   (T,L), S |- F 
%           U

% To execute: consult('your_file.pl'). verify('input.txt').

% see if presenece of X is true for input state (s0, s1, etc...)
check(_, Labels, CurrentState, [], X) :- 
    member([CurrentState, Props], Labels),
    member(X, Props).

% see if absence of X is true for input state (s0, s1, etc...)
check(_, Labels, CurrentState, [], neg(X)) :- 
    member([CurrentState, Props], Labels),
    \+member(X, Props).

% And - is both F and G true for current state?
check(Transitions, Labels, CurrentState, [], and(F,G)) :- 
    check(Transitions, Labels, CurrentState, [], F),
    check(Transitions, Labels, CurrentState, [], G).

% Or - is one of F or G true for current state?
check(Transitions, Labels, CurrentState, [], or(F,G)) :- 
    (check(Transitions, Labels, CurrentState, [], F) ; 
    check(Transitions, Labels, CurrentState, [], G)).

% AX - Do all next states to CurrentState hold true for F?
check(Transitions, Labels, CurrentState, [], ax(F)) :-
    member([CurrentState, Successors], Transitions),
    forall(
        member(NextState, Successors), 
        check(Transitions, Labels, NextState, [], F)
    ).

% EX - Does there exist a next state to CurrentState that hold true for F?
check(Transitions, Labels, CurrentState, [], ex(F)) :-
    member([CurrentState, Successors], Transitions),
    member(NextState, Successors),
    check(Transitions, Labels, NextState, [], F).

% AG - Does F hold true along every possible path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, ag(F)) :-
    (member(CurrentState, Visited) ->
        true
    ;
        % If not visited, perform the AG check
        (
            % Ensure F holds in the current state
            check(Transitions, Labels, CurrentState, [], F),
            % Get the successors of the current state
            member([CurrentState, Successors], Transitions),
            % Recursively check AG for all successors
            forall(
                member(Successor, Successors),
                check(Transitions, Labels, Successor, [CurrentState|Visited], ag(F))
            )
        )
    ).

% Helper predicate to find if something exists
exists(Condition, Goal) :-  
    call(Condition),        % Call condition 
    call(Goal).             % If condition is true, eval goal

% EG - Does F hold true along at least one possible path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, eg(F)) :-
    (member(CurrentState, Visited) ->
        true
    ;
        (
        % check if F is valid for current state, ex. if F=p is true for state CurrentState=s0
        check(Transitions, Labels, CurrentState, [], F),
        member([CurrentState, Successors], Transitions),
        exists(
            member(Successor, Successors),
            check(Transitions, Labels, Successor, [CurrentState | Visited], eg(F))
            ) 
        )    
    ).

% EF - Does there exist at least one path in which F will eventually hold true?
check(Transitions, Labels, CurrentState, Visited, ef(F)) :- 
    (check(Transitions, Labels, CurrentState, [], F) ->
        true
        ;
        (\+member(CurrentState, Visited) ->
            member([CurrentState, Successors], Transitions),
            exists(
                member(Successor, Successors),
                check(Transitions, Labels, Successor, [CurrentState|Visited], ef(F))
            )
        )
    ).

% AF - Will F eventually hold true for every existing path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, af(F)) :-
    (check(Transitions, Labels, CurrentState, [], F) ->
        true
        ;
        (\+member(CurrentState, Visited) ->
            member([CurrentState, Successors], Transitions),
            forall(
                member(Successor, Successors),
                check(Transitions, Labels, Successor, [CurrentState|Visited], af(F))
            )
        )
    ).
    
