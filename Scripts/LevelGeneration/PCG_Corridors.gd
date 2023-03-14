class_name PCG_Corridors
extends Node
# Author: Yalmaz
# Description: This class implements builds corridors using simple manhattan traversal

# Description: Initalize random number generator.
var rng = RandomNumberGenerator.new()
func _init():
	rng.randomize()


# Description: Connect together rooms with corridors
func connect_rooms(room_centers,brush_size):
	var start_room = rng.randi_range(0,room_centers.size()-1)
	var current_room = room_centers[start_room]
	room_centers.erase(current_room)
	
	var corridors = []
	while(room_centers.size()>0):
		#find closest room
		var next_room = _get_closest_room(current_room,room_centers)
		#pop that room
		room_centers.erase(next_room)
		#make corridor to that room
		corridors += _make_corridor(current_room,next_room,brush_size)
		current_room = next_room
	return corridors


# Description: Get closest room
func _get_closest_room(current, room_centers = []):
	var closest
	var min_dis = 10000000000
	for center in room_centers:
		var curr_dis = center.distance_squared_to(current)
		if curr_dis<min_dis:
			closest = center
			min_dis = curr_dis
	return closest


# Description: Build corridor based on brush width
func _make_corridor(current,next,brush_size):
	var corridor = []
	while current!=next:
		if current.x < next.x:
			current.x += 1
		elif current.x > next.x:
			current.x -= 1
		elif current.y<next.y:
			current.y += 1
		elif current.y>next.y:
			current.y -= 1
		
		for i in brush_size:
			for j in brush_size:
				corridor.push_back(current+Vector2(i,j))
	return corridor 
