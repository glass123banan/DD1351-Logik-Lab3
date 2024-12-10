% Load model, initial state and formula from file.
verify(Input) :-
    see(Input), read(Transitions), read(Labels), read(CurrentState), read(Formula), seen,
    check(Transitions, Labels, CurrentState, [], Formula).

% To execute: consult('your_file.pl'). verify('input.txt').

% see if presenece of X is true for input state (s0, s1, etc...)
check(_, Labels, CurrentState, [], X) :- 
    member([CurrentState, Props], Labels),      % find ex. [s0, [p, r, ...]] in Labels 
    member(X, Props).                           % check if the input X is present in [p, r, ...]

% see if absence of X is true for input state (s0, s1, etc...)
check(_, Labels, CurrentState, [], neg(X)) :- 
    member([CurrentState, Props], Labels),      % find ex. [s0, [p, r, ...]] in Labels
    \+member(X, Props).                         % check if the input X is NOT present in [p, r, ...]

% And - is both F and G true for current state?
check(Transitions, Labels, CurrentState, [], and(F,G)) :- 
    check(Transitions, Labels, CurrentState, [], F),        % call check on formula F
    check(Transitions, Labels, CurrentState, [], G).        % call check on formula G

% Or - is one of F or G true for current state?
check(Transitions, Labels, CurrentState, [], or(F,G)) :- 
    (check(Transitions, Labels, CurrentState, [], F) ;      % call check on both and see if at least one is true
    check(Transitions, Labels, CurrentState, [], G)).

% AX - Do all next states to CurrentState hold true for F?
check(Transitions, Labels, CurrentState, [], ax(F)) :-
    member([CurrentState, Successors], Transitions),        % Retrieve all successors of ex. s0
    forall(                                                 % check ALL successors to CurrentState
        member(NextState, Successors),                      % retrieve a state in Successors
        check(Transitions, Labels, NextState, [], F)        % see if input formula F is true in state
    ).

% EX - Does there exist a next state to CurrentState that hold true for F?
check(Transitions, Labels, CurrentState, [], ex(F)) :-
    member([CurrentState, Successors], Transitions),        % retrieve all successors of ex. s0
    member(NextState, Successors),                          % retrieve one arbitrary next state to s0
    check(Transitions, Labels, NextState, [], F).           % check if F holds true there

% AG - Does F hold true along every possible path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, ag(F)) :-
    (member(CurrentState, Visited) ->                       % if current state is already visited
        true                                                % proceed
    ;
        % If not visited, perform the AG check
        (
            % Ensure F holds in the current state
            check(Transitions, Labels, CurrentState, [], F),
            % Get the successors of the current state
            member([CurrentState, Successors], Transitions),
            % Recursively check AG for all successors
            forall(
                % for all successors, check AG and add currentstate to visited
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
    (member(CurrentState, Visited) ->           % check if currentstate is visited
        true
    ;
        (
        % check if F is valid for current state, ex. if F=p is true for state CurrentState=s0
        check(Transitions, Labels, CurrentState, [], F),
        member([CurrentState, Successors], Transitions),    % retrieve successors
        % is there any member of successors which will lead to an entire path where F holds true
        exists(
            member(Successor, Successors),
            check(Transitions, Labels, Successor, [CurrentState | Visited], eg(F))      % recursive call
            ) 
        )    
    ).

% EF - Does there exist at least one path in which F will eventually hold true?
check(Transitions, Labels, CurrentState, Visited, ef(F)) :- 
    (check(Transitions, Labels, CurrentState, [], F) ->         % if F holds true in currentstate, stop
        true
        ;
        (\+member(CurrentState, Visited) ->                     % otherwise, if currentstate is not visited...
            member([CurrentState, Successors], Transitions),    % find all successors
            exists(
                member(Successor, Successors),                  % find successor 
                check(Transitions, Labels, Successor, [CurrentState|Visited], ef(F))    % recursive call
            )
        )
    ).

% AF - Will F eventually hold true in a future state for every existing path from CurrentState?
check(Transitions, Labels, CurrentState, Visited, af(F)) :-
    (check(Transitions, Labels, CurrentState, [], F) ->         % if F holds true in current state, stop
        true
        ;
        (\+member(CurrentState, Visited) ->                     % if not visited
            member([CurrentState, Successors], Transitions),    % find successors
            % find all paths until all paths have one node where F holds true
            forall(
                member(Successor, Successors),
                check(Transitions, Labels, Successor, [CurrentState|Visited], af(F))
            )
        )
    ).
    
