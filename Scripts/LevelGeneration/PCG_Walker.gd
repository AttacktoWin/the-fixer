class_name PCG_Walker
extends Node
# Author: Yalmaz
# Description: This class implements room generation using binary space partition

enum {N,S,E,W}
var DIRECTIONS = {
	N:Vector2(0,1),
	S:Vector2(0,-1),
	E:Vector2(1,0),
	W:Vector2(-1,0),
}

# Walker run time values
var steps_since_turn = 0

# Description: Initalize random number generator.
func _init():
	randomize()
#var path = []
#	var room_list = []
#	var room_centers = []
#	var path_by_rooms = {}

# Description: Nothing much too look at here. Its a simple random walking algo.
func random_walk(
		walk_area:Rect2,					#param:specifies the size of the map, used in boundary cehcks by walker
		start_position:Vector2,				#param:where the walker will start.
		start_direction,					#param:which direction the walker starts walking in.
		walk_length:int,					#param:how far the walker will go, each step is a tile.
		random_turn_chance := 0.5,			#param:how likely it is for the walker to make a random turn.
		max_steps_in_direction := 2,		#param:how far the the walker will walk in one direction.
		corridor_size = 3
	):
	var path = []
	var direction = DIRECTIONS[start_direction]
	#dd current before walking begins
	var curr_position  = start_position
	var c2 = floor(corridor_size/2)
	for i in range(-c2,c2+1):
		for j in range(-c2,c2+1):
			path.push_back(curr_position+Vector2(i,j))
	for step in walk_length:
		#check if walker should change direction.
		if (
			self.steps_since_turn >= max_steps_in_direction or						# if walked more than max steps.
			randf() <= random_turn_chance or									# or if its time to randomly turn.
			not _is_valid_step(walk_area,corridor_size,curr_position,direction)	# or it its not a valid step.
			):
			direction = _change_direction(walk_area,corridor_size,curr_position,direction)
		else:
			curr_position = _take_valid_step(curr_position,direction,corridor_size,path)
	return path


# Description: tries to find a valid direction for the walker to move int
func _change_direction(
	walk_area,
	corridor_size,
	curr_position:Vector2,			#param: current position the walker is on
	curr_direction = Vector2(0,0)	#param: current direction the walker is moving in
	)->Vector2:
	#reset step counter
	self.steps_since_turn = 0
	#get random direction
	var direction_stack = DIRECTIONS.values()
	direction_stack.erase(curr_direction)
	direction_stack.shuffle()
	curr_direction = direction_stack.pop_front()
	#keep trying to get direction untill a valid step is found
	while direction_stack.size()>0 and not _is_valid_step(walk_area,corridor_size,curr_position,curr_direction):
		curr_direction = direction_stack.pop_front()
	return curr_direction


# Description: check if parameters give a valid step; mostly exits to help with readability
func _is_valid_step(
	walk_area,
	corridor_size,
	curr_position:Vector2,
	current_direction:Vector2
	)->bool:
	var rect = Rect2(curr_position+(current_direction*corridor_size),Vector2(corridor_size,corridor_size))
	if walk_area.encloses(rect):
		return true
	return false


# Description: walker takes a new step
func _take_valid_step(
	curr_position:Vector2,
	current_direction:Vector2,
	corridor_size,
	path
	):
	self.steps_since_turn+=1
	var new_position = curr_position+(current_direction*corridor_size)
	for i in corridor_size:
		for j in corridor_size:
			path.push_back(new_position+Vector2(i,j))
	return new_position
