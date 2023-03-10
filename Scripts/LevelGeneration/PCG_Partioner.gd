class_name PCG_Partioner
extends Node2D

var rng = RandomNumberGenerator.new()

var space = Rect2(0,0,60,60)
var min_width = 15
var min_height = 15
var shrink_factor = 3

func _init():
	rng.randomize()


func room_builder():
	var path = []
	var room_list = _binary_space_partition()
	for room in room_list:
		for i in range(room.position.x+self.shrink_factor,room.end.x-self.shrink_factor):
			for j in range(room.position.y+self.shrink_factor,room.end.y-self.shrink_factor):
				if path.find(Vector2(i,j)) != -1:
					print("overlaps %s" %[Vector2(i,j)]) #ur bsp is fucking up
				path.push_back(Vector2(i,j))
	return [path,room_list]


func _binary_space_partition():
	var room_queue = []
	var room_list = []
	room_queue.push_back(self.space)
	
	while(room_queue.size()>0):
		var candidate:Rect2 = room_queue.pop_front()
		if candidate.size.x > min_width*2:
			# warning-ignore:narrowing_conversion
			var new_partitions = _split(candidate,candidate.size.x,true)
			room_queue.push_back(new_partitions[0])
			room_queue.push_back(new_partitions[1])
		elif candidate.size.y > min_height*2:
			# warning-ignore:narrowing_conversion
			var new_partitions = _split(candidate,candidate.size.y,false)
			room_queue.push_back(new_partitions[0])
			room_queue.push_back(new_partitions[1])
		elif candidate.size.x >= min_width && candidate.size.y >= min_height:
			room_list.push_back(candidate)
	return room_list


func _split(split_candidate:Rect2,upper_bound:int,vertical=false):
	
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
