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
    member(X, Props), 
    write('Checking if literal is true: '), write(X), write(Props), nl.

% see if absence of X is true for input state (s0, s1, etc...)
check(_, Labels, CurrentState, [], neg(X)) :- 
    member([CurrentState, Props], Labels),
    \+member(X, Props),
    write('Checking if neg is true'), nl.

% And - is both F and G true for current state?
check(Transitions, Labels, CurrentState, [], and(F,G)) :- 
    check(Transitions, Labels, CurrentState, [], F),
    check(Transitions, Labels, CurrentState, [], G), 
    write('Checking for and...'), nl.

% Or - is one of F or G true for current state?
check(Transitions, Labels, CurrentState, [], or(F,G)) :- 
    (check(Transitions, Labels, CurrentState, [], F) ; 
    check(Transitions, Labels, CurrentState, [], G)), 
    write('Checking for or...'), nl.

% AX - Do all next states to CurrentState hold true for F?
check(Transitions, Labels, CurrentState, [], ax(F)) :-
    member([CurrentState, Successors], Transitions),
    forall(
        member(NextState, Successors), 
        check(Transitions, Labels, NextState, [], F)
    ),
    write('Checking for ax...'), nl.

% EX - Does there exist a next state to CurrentState that hold true for F?
check(Transitions, Labels, CurrentState, [], ex(F)) :-
    member([CurrentState, Successors], Transitions),
    member(NextState, Successors),
    check(Transitions, Labels, NextState, [], F),
    write('Checking for ex...'), nl.

% AG - Does F hold true along every possible path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, ag(F)) :-
    write('Current state: '), write(CurrentState), nl, 
    write('Visited: '), write(Visited), nl, 
    (member(CurrentState, Visited) ->
        write('State already visited, skipping further checks...'), nl
    ;
        % If not visited, perform the AG check
        (
            % Ensure F holds in the current state
            check(Transitions, Labels, CurrentState, [], F),
            % Get the successors of the current state
            member([CurrentState, Successors], Transitions),
            write('Successors: '), write(Successors), nl,
            % Recursively check AG for all successors
            forall(
                member(Successor, Successors),
                check(Transitions, Labels, Successor, [CurrentState|Visited], ag(F))
            ),
            write('AG condition satisfied for state: '), write(CurrentState), nl
        )
    ),
    write('Checking AG...'), nl.

% Helper predicate to find if something exists
exists(Condition, Goal) :-  
    call(Condition),        % Call condition 
    call(Goal).             % If condition is true, eval goal

% EG - Does F hold true along at least one possible path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, eg(F)) :-
    write('Current state: '), write(CurrentState), nl, 
    write('Visited: '), write(Visited), nl,
    (member(CurrentState, Visited) ->
        write('State is already visited, skipping further checks...')
        % write 'true' instead of write later
    ;
        (
        % check if F is valid for current state, ex. if F=p is true for state CurrentState=s0
        check(Transitions, Labels, CurrentState, [], F),
        member([CurrentState, Successors], Transitions),
        write('Successors: '), write(Successors), nl, 
        exists(
            member(Successor, Successors),
            check(Transitions, Labels, Successor, [CurrentState | Visited], eg(F))
        ), 
        write('EG checked for state: '), write(CurrentState), nl
        )    
    ), 
    write('Checking EG...'), nl.

% EF - Does there exist at least one path in which F will eventually hold true?
check(Transitions, Labels, CurrentState, Visited, ef(F)) :-
    write('Current state: '), write(CurrentState), nl, 
    write('Visited: '), write(Visited), nl, 
    (check(Transitions, Labels, CurrentState, [], F) ->
        write('State is true for current state...')
        ;
        (\+member(CurrentState, Visited) ->
            member([CurrentState, Successors], Transitions),
            exists(
                member(Successor, Successors),
                check(Transitions, Labels, Successor, [CurrentState|Visited], ef(F))
            )
        )
    ),
    write('Checking for EF...'), nl.

% AF - Will F eventually hold true for every existing path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, af(F)) :-
    write('Current state: '), write(CurrentState), nl, 
    write('Visited: '), write(Visited), nl, 
    (\+member(CurrentState, Visited) ->
        check(Transitions, Labels, CurrentState, [], F),
        member([CurrentState, Successors], Transitions),
        forall(
            member(Successor, Successors),
            check(Transitions, Labels, Successor, [CurrentState|Visited], af(F))
            % (check(Transitions, Labels, Successor, [CurrentState|Visited], af(F)) -> 
            %     last([CurrentState|Visited], LastElement),
            %     check(Transitions, Labels, LastElement, [], F)
            % )
        ),

        check(Transitions, Labels, CurrentState, [], F)
    ),
    write('Checking for AF...'), nl.
