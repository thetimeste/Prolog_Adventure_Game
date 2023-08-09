% Dynamic variable to hold the current state
:- dynamic current_state/1.

% Locations
location(outside).
location(cave).
location(house).

% Define the available items
item(sword).
item(shield).

% Define the initial location of items
item_location(sword, outside).
item_location(shield, house).

% Define the location of the cave, house, and the monster
house_location(house,north).
cave_location(cave,south).
monster_location(monster, cave).

% Initial state
state(outside,[],alive).
    
% Describe the situation based on the state
describe:-
    !,
    current_state(State),  % Get the current state
    State = state(Location, Inventory, _),  % Extract components of the state
    nl,
    write("You are in: "), write(Location), nl,
    write("You have the following items: "), list_items(Inventory), nl.

% Define a predicate to list items the player has
list_items([]) :- 
    write("none").
list_items([Item | Rest]) :-
    write(Item), write(", "),
    list_items(Rest).



move(north) :-
    current_state(State),
    State = state(Location, Inventory, Alive),
    write("current state: "), nl, write(Location), nl, write(Inventory), nl, write(Alive),nl,  % Get the current state
    retractall(current_state(_)),  % Remove all existing states
    NewState = state(house,_, alive), %state entering the house
    assertz(current_state(NewState)),    % Add new state
    write("You have entered the house."), nl,
    describe.  % Describe new state

move(south) :-
    
    current_state(State),
    State = state(Location, Inventory, Alive),
    write("current state: "), nl, write(Location), nl, write(Inventory), nl, write(Alive),nl,  % Get the current state
    Location \= house, %if player is in house it can only go north and exit the house
    retractall(current_state(_)),  % Remove all existing states
    NewState = state(house,Inventory, Alive), %state entering the house
    assertz(current_state(NewState)),    % Add new state
    write("You have entered the house."), nl,
    describe.  % Describe new state

move(west) :-
    current_state(State),
    State = state(Location, Inventory, Alive),
    write("current state: "), nl, write(Location), nl, write(Inventory), nl, write(Alive),nl,  % Get the current state
    Location \= house, %if player is in house it can only go north and exit the house
    retractall(current_state(_)),  % Remove all existing states
    NewState = state(outside,_, alive), %state entering the house
    assertz(current_state(NewState)),    % Add new state
    write("You have entered the house."), nl,
    describe.  % Describe new state

move(east) :-
    current_state(State),
    State = state(Location, Inventory, Alive),
    write("current state: "), nl, write(Location), nl, write(Inventory), nl, write(Alive),nl,  % Get the current state
    Location \= house, %if player is in house it can only go north and exit the house
    retractall(current_state(_)),  % Remove all existing states
    NewState = state(outside,_, alive), %state entering the house
    assertz(current_state(NewState)),    % Add new state
    write("You have entered the house."), nl,
    describe.  % Describe new state

move(_) :- write("This move is forbidden").
    

% Initialize the game
start_game:-
    write("Welcome to the Adventure Game!"), 
    InitialState = state(outside,[],alive),
    assertz(current_state(InitialState)),  % Store initial state
    describe.