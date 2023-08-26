% Dynamic predicates to hold the current state
:- dynamic current_state/1.
:- dynamic chest_state/1.
:- dynamic monster_state/1.

% Initial state
current_state(state(outside,[])).
chest_state(closed).
monster_state(alive).

% Describes the player's situation
describe:-
    current_state(State),  % Get the current state
    State = state(Location, Inventory),  % Extract components of the state
    nl,
    write("Your current position: "), write(Location), nl,
    write("You have the following items: "), list_items(Inventory), nl.

% Describes the environment around the player
% Outside and monster alive
look(outside):- 
    monster_state(MonsterState),
    MonsterState==alive,
    write("You can see a house to the south, a cave to the north, a precipice to the west, a river to the east"),nl.
% Outside and monster dead (win)
look(outside):- 
    monster_state(MonsterState),
    MonsterState==dead,
    win,!.

look(house):- write("You see a chest to the south and nothing else worth in the house"),nl.
look(chest):- write("You see a giant chest, try to open it"),nl.
look(river):- write("You see a nice river with a shadow under the water, try to pick that object up"),nl.
look(precipice):- write("You see a warning sign that says 'DANGER AHEAD DO NO CROSS' "),nl.
look(hole):- write("You fall down the precipice and die..."),nl,die. 

% cave with monster alive
look(cave):- 
    monster_state(MonsterState),
    MonsterState==alive,
    write("You are entering a cave, it might be dangerous to go north"),nl.
% cave with monster dead
look(cave):- 
    monster_state(MonsterState),
    MonsterState==dead,
    write("You are entering the cave that is safe, the cave goes deeper to the north, the exit is to the south"),nl.
% cave2 with monster alive
look(cave2):- 
    monster_state(MonsterState),
    MonsterState==alive,
    write("You are deep into the cave and hear loud scary noises from east, the monster must be hiding there"),nl.
% cave2 with monster dead
look(cave2):- 
    monster_state(MonsterState),
    MonsterState==dead,
    write("You are deep into the cave and its silent, light comes from south, a terrible smell comes from east"),nl.


% player ecounters monster with sword and shield
look(monster):-
    monster_state(MonsterState),
    MonsterState==alive,
    current_state(State),
    State = state(Location, Inventory),
    is_item_in_list(shield,Inventory),
    is_item_in_list(sword,Inventory),
    monster_state(MonsterState),
    MonsterState==alive,
    write("You see a giant monster approaching"),nl,
    write("the monster attacks you"),nl,
    write("you parry the monster attack, the shield breaks"),nl,
    write("you strike a powerful attack with your sword"),nl,
    write("the monster loudly screams and falls on the ground"),nl,
    write("the monster is dead"),nl,
    retract(monster_state(MonsterState)),
    MonsterNewState=dead,
    assertz(monster_state(MonsterNewState)),
    write("you can exit the cave..."),nl.

% player ecounters monster with shield
look(monster):-
    monster_state(MonsterState),
    MonsterState==alive,
    current_state(State),
    State = state(Location, Inventory),
    is_item_in_list(shield,Inventory),
    write("You see a giant monster approaching"),nl,
    write("the monster attacks you"),nl,
    write("you parry the monster attack, the shield breaks"),nl,
    write("you have no items to attack the monster that is preparing to attack again"),nl,
    write("the monster attacks and you die."),nl,die.

% player ecounters monster with sword  
look(monster):-	
    monster_state(MonsterState),
    MonsterState==alive,
    current_state(State),
    State = state(Location, Inventory),
    is_item_in_list(sword,Inventory),
    write("You see a giant monster approaching"),nl,
    write("you try to immediately attack with your sword, but the monster is faster"),nl,
    write("you have no items to parry the monsters attack"),nl,
    write("the monster attacks and you die."),nl,die.

% player ecounters monster with no items                                                         
look(monster):- 
    monster_state(MonsterState),
    MonsterState==alive,
    write("You see a giant monster approaching"),nl,
    write("you have no items to attack nor defend yourself"),nl,
    write("the monster attacks and you die."),nl,die.

% player ecounters dead monster  
look(monster):-
    monster_state(MonsterState),
    MonsterState==dead,
    write("You see a giant monster dead to the ground"),nl.


%search for item in list
is_item_in_list(Item, [Item | _]).

is_item_in_list(Item, [_ | Rest]) :-
    is_item_in_list(Item, Rest).

% list items the player has
list_items([]) :- 
    write(".").
list_items([Item | Rest]) :-
    write(Item), write(" "),
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
path(monster,west,cave2).
                           
%paths from river
path(river,west,outside).
                           
%paths from precipice
path(precipice,east,outside).
path(precipice,west,hole).

%pickup shield if chest is open
pickup:-
    current_state(State),
    chest_state(ChestState),
    State = state(Location, Inventory),
    Location == chest,
    ChestState == open,
    append(Inventory, [shield], NewInventory),
    NewState = state(Location,NewInventory), %state picking up shield
    retract(current_state(State)),
    assertz(current_state(NewState)),    % Add new state
    write("Shield has been added to your inventory."),
    describe.

%pickup sword
pickup:-
    current_state(State),
    State = state(Location, Inventory),
    Location == river,
    append(Inventory, [sword], NewInventory),
    NewState = state(Location,NewInventory), %state picking up shield
    retract(current_state(State)),
    assertz(current_state(NewState)),    % Add new state
    write("Sword has been added to your inventory."),nl,
    describe.

%prompt to open the chest
pickup:-
    chest_state(ChestState),
    ChestState == closed,
    write("The chest is closed, open it to pick up whats inside"),nl.
   
pickup:-
    write("There is nothing to pick up here."),nl.

open:-
    chest_state(ChestState),
    current_state(State),
    State = state(Location, Inventory),
    Location == chest,
    ChestState == closed,
    NewChestState = open,
    retract(chest_state(ChestState)),
    assertz(chest_state(NewChestState)),  
    write("You open the chest, there is a golden shield inside."),nl.

open:-
    chest_state(ChestState),
    current_state(State),
    State = state(Location, Inventory),
    Location == chest,
    ChestState == open,
    write("The chest is already open."),nl.

open:- write("There is nothing to open here"),nl.

n:- move(north).
s:-move(south).
e:-move(east).
w:-move(west).

move(Direction) :-
    write("Moving "),write(Direction),write("..."),nl,
    current_state(State),
    State = state(Location, Inventory),
    path(Location, Direction, There),
    NewState = state(There,Inventory), %state entering the house
    retract(current_state(State)),
    assertz(current_state(NewState)),    % Add new state
    location,
    look(There).  % Describe new state


move(_) :- write("Cant go that way..."),nl.

status:-	write(" --- status ---"),describe.
location:-	current_state(State),
    		State = state(Location, Inventory),
    		write("You are in: "),write(Location),nl.

% Handle game over
die :-
nl,
write("Game Over"),
halt.

% Handle win
win :-
nl,
write("CONGRATULATIONS YOU KILLED THE MONSTER AND WON THE GAME!!!"),
halt.

% Initialize the game
start:-
    write("Welcome to the Adventure Game!"),nl, 
    write("Your task is to kill the monster in the cave!"),nl,
    write("Explore the environment to find useful items"),nl,
    write("### COMMANDS ###"),nl,
    write("n, s, e, w -> makes the player move north, south, east, west"),nl,
    write("pickup -> pick up items nearby"),nl,
    write("open -> open chests"),nl,
    write("status -> description of your inventory and current location in the map"),nl,
    write("### GAME STARTED ###"),nl,
    describe,
    look(outside).
