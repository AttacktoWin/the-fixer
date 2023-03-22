class_name PCG_Partioner
extends Node2D
# Author: Yalmaz
# Description: This class implements room generation using binary space partition

# Partitioner parameters
var rng = RandomNumberGenerator.new()


# Description: Initalize random number generator.
func _init():
	rng.randomize()


# Description: Use binary space partition to build the rooms.
func room_builder(
	space:Rect2,		#param:specifies the size of the map
	width:int,			#param:specifies the min width of the generated rooms
	height:int,			#param:specifies the min height of the generated rooms
	shrink_factor:int	#param: specifies the shrink value for the space between rooms.
	):
	var path = []
	var path_by_room = {}
	var room_list = binary_space_partition(space,width,height)
	var room_centers = []
	for room in room_list:
		path_by_room[room] = []
		var center = room.get_center()
		room_centers.push_back(Vector2(floor(center.x),floor(center.y)))
		for i in range(room.position.x+shrink_factor,
					   room.end.x-shrink_factor):
			for j in range(room.position.y+shrink_factor,
						   room.end.y-shrink_factor):
				path.push_back(Vector2(i,j))
				path_by_room[room].push_back(Vector2(i,j))
	return [path,room_list,room_centers,path_by_room]


# Description: Nothing much to look at here, its a simple bsp algo that returns 
# rooms. Can be used in combination with walker for natural looking rooms
func binary_space_partition(
	space:Rect2,			#param:specifies the size of the map
	min_width:int,			#param:specifies the min width of the generated rooms
	min_height:int			#param:specifies the min height of the generated rooms
	):
	var room_queue = []
	var room_list = []
	room_queue.push_back(space)
	
	while(room_queue.size()>0):
		var candidate:Rect2 = room_queue.pop_front()
		if candidate.size.x > min_width*2:
			# warning-ignore:narrowing_conversion
			var new_partitions = _split(min_width,min_height,candidate,candidate.size.x,true)
			room_queue.push_back(new_partitions[0])
			room_queue.push_back(new_partitions[1])
		elif candidate.size.y > min_height*2:
			# warning-ignore:narrowing_conversion
			var new_partitions = _split(min_width,min_height,candidate,candidate.size.y,false)
			room_queue.push_back(new_partitions[0])
			room_queue.push_back(new_partitions[1])
		elif candidate.size.x >= min_width && candidate.size.y >= min_height:
			room_list.push_back(candidate)
	return room_list


# Description: split a rectangle into two based on a random split value. It
# splits horizontally or vertiaclly based on the prvovided bool.
func _split(
	min_width:int,min_height:int,
	split_candidate:Rect2,
	upper_bound:int,vertical=false
	):
	var position_a
	var position_b
	var size_a
	var size_b
	if vertical:
		var split_value = rng.randi_range(min_width,upper_bound)
		position_a = split_candidate.position
		position_b = Vector2(split_candidate.position.x + split_value,split_candidate.position.y)
		size_a = Vector2(split_value,split_candidate.size.y)
		size_b = Vector2(split_candidate.size.x - split_value,split_candidate.size.y)
	else:
		var split_value = rng.randi_range(min_height,upper_bound)
		position_a = split_candidate.position
		position_b = Vector2(split_candidate.position.x,split_value+split_candidate.position.y)
		size_a = Vector2(split_candidate.size.x,split_value)
		size_b = Vector2(split_candidate.size.x,split_candidate.size.y - split_value)
	return [Rect2(position_a,size_a),Rect2(position_b,size_b)]

func get_centers(room_list):
	var centers = []
	for room in room_list:
		var center = room.get_center()
		centers.push_back(Vector2(floor(center.x),floor(center.y)))
	return centers
