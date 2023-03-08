class_name PCG_Partioner
extends Node2D

var rng = RandomNumberGenerator.new()

var space = Rect2(0,0,60,60)
var min_width = 15
var min_height = 15
var offset = 4

func _init():
	rng.randomize()


func room_builder():
	var path = []
	var room_list = _binary_space_partition()
	print(room_list)
	for room in room_list:
		for i in range(room.position.x+self.offset,room.end.x-self.offset):
			for j in range(room.position.y+self.offset,room.end.y-self.offset):
				if path.find(Vector2(i,j)) != -1:
					print("overlaps") #ur bsp is fucking up
				path.push_back(Vector2(i,j))
	path += _connect_rooms(room_list)
	return path

func _binary_space_partition():
	var room_queue = []
	var room_list = []
	room_queue.push_back(self.space)

	while(room_queue.size()>0):
		var candidate:Rect2 = room_queue.pop_front()
		if candidate.size.x >= min_width && candidate.size.y >= min_height:
			if(false):
				if candidate.size.x > min_width*2:
					var new_partitions = _split(candidate,candidate.size.x,true)
					room_queue.push_back(new_partitions[0])
					room_queue.push_back(new_partitions[1])
				elif candidate.size.y > min_height*2:
					var new_partitions = _split(candidate,candidate.size.y,false)
					room_queue.push_back(new_partitions[0])
					room_queue.push_back(new_partitions[1])
				else:
					room_list.push_back(candidate)
			else:
				if candidate.size.y > min_height*2:
					var new_partitions = _split(candidate,candidate.size.y,false)
					room_queue.push_back(new_partitions[0])
					room_queue.push_back(new_partitions[1])
				elif candidate.size.x > min_width*2:
					var new_partitions = _split(candidate,candidate.size.x,true)
					room_queue.push_back(new_partitions[0])
					room_queue.push_back(new_partitions[1])
				else:
					room_list.push_back(candidate)
	return room_list


func _split(split_candidate:Rect2,upper_bound:int,vertical=false):
	var rect_a
	var rect_b
	
	if vertical:
		var split_value = rng.randi_range(min_width,upper_bound)
		rect_a = Rect2(
			split_candidate.position,
			Vector2(split_value,split_candidate.size.y)
			)
		rect_b = Rect2(
			Vector2(split_value,split_candidate.position.y),
			Vector2(split_candidate.size.x - split_value,split_candidate.size.y)
			)
	else:
		var split_value = rng.randi_range(min_height,upper_bound)
		rect_a = Rect2(
			split_candidate.position,
			Vector2(split_candidate.size.x,split_value)
			)
		rect_b = Rect2(
			Vector2(split_candidate.position.x,split_value),
			Vector2(split_candidate.size.x,split_candidate.size.y - split_value)
			)
	return [rect_a,rect_b]

func _connect_rooms(room_list):
	var room_centers = []
	for room in room_list:
		var center = room.get_center()
		room_centers.push_back(Vector2(floor(center.x),floor(center.y)))
	
	var start_room = rng.randi_range(0,room_centers.size()-1)
	var current_room = room_centers[start_room]
	room_centers.erase(room_centers)
	
	var corridors = []
	while(room_centers.size()>0):
		#find closest room
		var next_room = _get_closest_room(current_room,room_centers)
		#pop that room
		room_centers.erase(next_room)
		#make corridor to that room
		corridors += _make_corridor(current_room,next_room)
		current_room = next_room
	return corridors

func _get_closest_room(current, room_centers = []):
	var closest
	var min_dis = 10000000000
	for center in room_centers:
		var curr_dis = center.distance_squared_to(current)
		if curr_dis<min_dis:
			closest = center
			min_dis = curr_dis
	return closest
	
func _make_corridor(current,next):
	var corridor = []
	var count = 0
	while current!=next:
		count+=1
		if current.x < next.x:
			current.x += 1
		elif current.x > next.x:
			current.x -= 1
		elif current.y<next.y:
			current.y += 1
		elif current.y>next.y:
			current.y -= 1
		corridor.push_back(current)
		print([current,next])
	return corridor 
	
