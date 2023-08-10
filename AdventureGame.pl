% Dynamic variable to hold the current state
:- dynamic current_state/1.

current_state(state(outside,[],alive)).

% Define the available items
item(sword).
item(shield).

% Define the initial location of items
item_location(sword, outside).
item_location(shield, house).

% Initial state
state(outside,[],alive).
    
% Describes the player's situation
describe:-
    current_state(State),  % Get the current state
    State = state(Location, Inventory, _),  % Extract components of the state
    nl,
    write("You are in: "), write(Location), nl,
    write("You have the following items: "), list_items(Inventory), nl.

% Describes the environment around the player
look(outside):- write("You can see a house to the south, a cave to the north, a precipice to the west, a river to the east"),nl.
look(house):- write("You see a chest to the south and nothing else worth in the house"),nl.
look(river):- write("You see a nice river with a shadow under the water, i wonder what it could be..."),nl.
look(precipice):- write("You see a warning sign that says 'DANGER AHEAD DO NO CROSS' "),nl.
look(cave):- write("You are into the cave and you hear noises from north, it might be dangerous to proceed"),nl.
look(cave2):- write("You are deep into the cave and hear loud scary noises from east, the monster must be hiding there"),nl.
look(monster):- write("A giant monster with big teeth that eats you as soon as he sees you"),nl,die.
look(hole):- write("You fall down the precipice and die..."),nl,die.
% Define a predicate to list items the player has
list_items([]) :- 
    write("none").
list_items([Item | Rest]) :-
    write(Item), write(", "),
    list_items(Rest).


%paths from outside 
path(outside,south,house).
path(outside,north,cave).
path(outside,east,river).
path(outside,west,precipice).

%paths in the house
path(house,north,outside).
path(house,south,chest).
path(chest,north,house).

%paths in the cave
path(cave,south,outside).
path(cave,north,cave2).
path(cave2,east,monster).
path(cave2,south,cave).
                           
%paths from river
path(river,west,outside).
                           
%paths from precipice
path(precipice,east,outside).
path(precipice,west,hole).

move(Direction) :-
    current_state(State),
    State = state(Location, Inventory, Alive),
    path(Location, Direction, There),
    NewState = state(There,_,_), %state entering the house
    retract(current_state(State)),
    assertz(current_state(NewState)),    % Add new state
    describe,
    look(There).  % Describe new state


move(_) :- write("This move is forbidden"),nl.

% Handle game over
die :-
        !, finish.
finish :-
        nl,
        write("Game Over"),
        nl, !.
    

% Initialize the game
start:-
    write("Welcome to the Adventure Game!"), 
    %InitialState = state(outside,[],alive),
    %assertz(current_state(InitialState)),  % Store initial state
    describe,
    look(outside).

% Demo1 - player goes into the monster
demo1:- 
    start,
    move(north),
    move(north),
    move(east).

% Demo2 - player goes down the precipice
demo2:-
    start,
    move(west),
    move(west).