class_name PCG_Partioner
extends Node2D
# Author: Yalmaz
# Description: This class implements room generation using binary space partition

var random
var space: Rect2
var width: int = 0
var height: int = 0
var shrink_factor: int = 0


# Description: initialize the class with fixed params
func construct(  #param:specifies the size of the map  #param:specifies the min width of the generated rooms  #param:specifies the min height of the generated rooms
	rng: RandomNumberGenerator, level_space: Rect2, s_width: int, s_height: int, shrink: int
):  #param: specifies the shrink value for the space between rooms.
	self.random = rng
	self.space = level_space
	self.width = s_width
	self.height = s_height
	self.shrink_factor = shrink


# Description: Use binary space partition to build the rooms.
func room_builder(o_path, o_path_by_room, o_room_list, o_room_centers):
	binary_space_partition(self.width, self.height, self.space, o_room_list)
	for room in o_room_list:
		o_path_by_room[room] = []
		var center = room.get_center()
		o_room_centers.push_back(Vector2(floor(center.x), floor(center.y)))
		for i in range(room.position.x + self.shrink_factor, room.end.x - self.shrink_factor):
			for j in range(room.position.y + self.shrink_factor, room.end.y - self.shrink_factor):
				o_path.push_back(Vector2(i, j))
				o_path_by_room[room].push_back(Vector2(i, j))


# Description: Nothing much to look at here, its a simple bsp algo that returns
# rooms. Can be used in combination with walker for natural looking rooms
func binary_space_partition(min_width: int, min_height: int, level_space: Rect2, o_room_list):  #param:specifies the min width of the generated rooms  #param:specifies the min height of the generated rooms  #param:specifies the size of the map
	var room_queue = []
	room_queue.push_back(level_space)

	while room_queue.size() > 0:
		var candidate: Rect2 = room_queue.pop_front()
		if candidate.size.x > min_width * 2:
			# warning-ignore:narrowing_conversion
			var new_partitions = _split(min_width, min_height, candidate, candidate.size.x, true)
			room_queue.push_back(new_partitions[0])
			room_queue.push_back(new_partitions[1])
		elif candidate.size.y > min_height * 2:
			# warning-ignore:narrowing_conversion
			var new_partitions = _split(min_width, min_height, candidate, candidate.size.y, false)
			room_queue.push_back(new_partitions[0])
			room_queue.push_back(new_partitions[1])
		elif candidate.size.x >= min_width && candidate.size.y >= min_height:
			o_room_list.push_back(candidate)


# Description: split a rectangle into two based on a random split value. It
# splits horizontally or vertiaclly based on the prvovided bool.
func _split(
	min_width: int, min_height: int, split_candidate: Rect2, upper_bound: int, vertical = false
):
	var position_a
	var position_b
	var size_a
	var size_b
	if vertical:
		var split_value = self.random.randi_range(min_width, upper_bound)
		position_a = split_candidate.position
		position_b = Vector2(split_candidate.position.x + split_value, split_candidate.position.y)
		size_a = Vector2(split_value, split_candidate.size.y)
		size_b = Vector2(split_candidate.size.x - split_value, split_candidate.size.y)
	else:
		var split_value = self.random.randi_range(min_height, upper_bound)
		position_a = split_candidate.position
		position_b = Vector2(split_candidate.position.x, split_value + split_candidate.position.y)
		size_a = Vector2(split_candidate.size.x, split_value)
		size_b = Vector2(split_candidate.size.x, split_candidate.size.y - split_value)
	return [Rect2(position_a, size_a), Rect2(position_b, size_b)]


# Description: get centers for the generated rooms
func get_centers(room_list):
	var centers = []
	for room in room_list:
		var center = room.get_center()
		centers.push_back(Vector2(floor(center.x), floor(center.y)))
	return centers
