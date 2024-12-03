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
    write("Checking if literal is true"), nl.

% see if absence of X is true for input state (s0, s1, etc...)
check(_, Labels, CurrentState, [], neg(X)) :- 
    member([CurrentState, Props], Labels),
    \+member(X, Props),
    write("Checking if neg is true"), nl.

% And
% check(Transitions, Labels, CurrentState, [], and(F,G)) :- 
%     ...

% Or
% check(Transitions, Labels, CurrentState, [], or(F,G)) :- 
%     ...

% AX
% EX
% AG
% EG
% EF
% AF