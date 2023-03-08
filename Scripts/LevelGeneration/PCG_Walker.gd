class_name PCG_Walker
extends Node

enum {N,S,E,W}
var DIRECTIONS = {
	N:Vector2(0,1),
	S:Vector2(0,-1),
	E:Vector2(1,0),
	W:Vector2(-1,0),
}

var area = Rect2(0,0,50,50)
var brush_size = 3

var steps_since_turn = 0
var path = []

func _init():
	randomize()

# Description: Constructor for the walker, helps set the major params
func construct(
		map_size:Vector2,	#param:specifies the size of the map, used in boundary cehcks by walker
		corridor_size:int	#param:specifies the corridors 
	):
	area = Rect2(0,0,map_size.x,map_size.y)
	brush_size = corridor_size


# Description: Nothing much too look at here. Its a simple random walking algo.
func random_walk(
		walk_length:int,					#param:how far the walker will go, each step is a tile.
		start_position:Vector2,				#param:where the walker will start.
		start_direction := DIRECTIONS[S],	#param:which direction the walker starts walking in.
		random_turn_chance := 0.25,			#param:how likely it is for the walker to make a random turn.
		max_steps_in_direction := 2			#param:how far the the walker will walk in one direction.
	):
	path = []
	var curr_position  = start_position
	var direction = DIRECTIONS[start_direction]
	
	for step in walk_length:
		#check if walker should change direction.
		if (
			steps_since_turn >= max_steps_in_direction or	# if walked more than max steps.
			randf() <= random_turn_chance or				# or if its time to randomly turn.
			not _is_valid_step(curr_position,direction)		# or it its not a valid step.
			):
			direction = _change_direction(curr_position,direction)
		else:
			curr_position = _take_valid_step(curr_position,direction)
	return path


# Description: tries to find a valid direction for the walker to move int
func _change_direction(
	curr_position:Vector2,			#param: current position the walker is on
	curr_direction = Vector2(0,0)	#param: current direction the walker is moving in
	)->Vector2:
	
	#reset step counter
	steps_since_turn = 0
	
	#get random direction
	var direction_stack = DIRECTIONS.values()
	direction_stack.erase(curr_direction)
	direction_stack.shuffle()
	curr_direction = direction_stack.pop_front()
	
	#keep trying to get direction untill a valid step is found
	while not _is_valid_step(curr_position,curr_direction):
		curr_direction = direction_stack.pop_front()
	return curr_direction


# Description: check if parameters give a valid step; mostly exits to help with readability
func _is_valid_step(curr_position:Vector2,current_direction:Vector2)->bool:
	var rect = Rect2(curr_position+(current_direction*brush_size),Vector2(brush_size,brush_size))
	if area.encloses(rect):
		return true
	return false


# Description: walker takes a new step
func _take_valid_step(curr_position:Vector2,current_direction:Vector2):
	steps_since_turn+=1
	var new_position = curr_position+(current_direction*brush_size)
	for i in brush_size:
		for j in brush_size:
			path.push_back(new_position+Vector2(i,j))
	return new_position
