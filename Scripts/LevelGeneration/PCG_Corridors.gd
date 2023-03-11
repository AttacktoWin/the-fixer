class_name PCG_Corridors
extends Node

var rng = RandomNumberGenerator.new()
var brush_size = 5

func _init():
	rng.randomize()

func connect_rooms(room_list):
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
		
		for i in brush_size:
			for j in brush_size:
				corridor.push_back(current+Vector2(i,j))
	return corridor 
