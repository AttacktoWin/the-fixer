class_name PCG_Populator
extends Node2D

var player
var goal
var max_per_room
var enemy_buffer
var enemy_info

var neighbours_kernel = [
	Vector2(0,1),
	Vector2(0,-1),
	Vector2(1,0),
	Vector2(-1,0),
	
	Vector2(1,1),
	Vector2(-1,1),
	Vector2(1,-1),
	Vector2(-1,-1),
]

func construct(
	_player,_goal,
	per_room,
	buffer,
	info):
	self.player = _player
	self.goal = _goal
	self.max_per_room = per_room
	self.enemy_buffer = buffer
	self.enemy_info = info


func populate(
	tile_map,
	path,path_by_room,
	room_list,room_centers,
	parent):
	#remove all tiles on edges to avoid clipping
	path_by_room = _remove_edges(path_by_room)
	_player_goal_pass(tile_map,path,room_list,room_centers)
	var spawn_data = _spawn_point_pass(room_list,path_by_room)
	var spawn_info = _hostile_selection_pass(spawn_data[0],spawn_data[1],spawn_data[2])
	spawn_pass(spawn_info,tile_map,parent)


func _remove_edges(path_by_room):
	var shrunk = {}
	for room in path_by_room:
		shrunk[room] = []
		for tile in path_by_room[room]:
			var test_status = true
			for neighbour in neighbours_kernel:
				var test = tile+neighbour
				if not (test in path_by_room[room]):
					test_status = false
					break
			if test_status:
				shrunk[room].append(tile)
	return shrunk


func _player_goal_pass(tile_map,path,room_list,room_centers):
	var start = room_centers.front()
	var pos = tile_map.map_to_world(start)
	player.global_position = tile_map.to_global(pos)
	#generate dijkstra map
	var d_map = gen_dijstra_map(start,path)
	#pick random high value tile
	var random_end = d_map.keys().slice(d_map.size()-10,d_map.size())
	random_end.shuffle()
	var exit = random_end[0]
	#loop over to find room
	for index in range(room_list.size()):
		if room_list[index].has_point(exit):
			exit = index
			#flatten space around center
			for x in range (-2,3):
				for y in range (-2,3):
					path.push_back(room_centers[index]+Vector2(x,y))
			#set room center as exit
			pos = tile_map.map_to_world(room_centers[index])
			goal.global_position = tile_map.to_global(pos)
			break


func _spawn_point_pass(room_list,path_by_room):
	var rooms = room_list.duplicate()
	rooms.remove(0)
	
	var spawn_candidates = path_by_room.duplicate(true)
	var spawn_by_room = {}
	var spawn_count = 0
	for room in rooms:
		var spawns = []
		spawn_candidates[room].shuffle()
		for enemy in range(self.max_per_room):
			spawn_count+=1
			var spawn = spawn_candidates[room].pop_front()
			for x in range(
				-self.enemy_buffer,
				self.enemy_buffer+1):
				for y in range(
					-self.enemy_buffer,
					self.enemy_buffer+1):
					var neighbour = Vector2(spawn.x-x,spawn.y-y)
					spawn_candidates[room].erase(neighbour)
			spawns.append(spawn)
			if spawn_candidates[room].size()==0:
				break
		spawn_by_room[room] = spawns
	return [spawn_count,spawn_by_room,rooms]


func _hostile_selection_pass(count,spawns,room_list):
	var spawn_by_room = spawns.duplicate()
	var room_que = _randomize_rooms(room_list)
	var spawn_info = {}
	var remaining = count
	
	for enemy in enemy_info:
		var current = floor(count*enemy_info[enemy][0]/100)
		remaining = remaining - current
		enemy_info[enemy][0] = current
	
	for enemy in enemy_info:
		spawn_info[enemy] = []
		for point in enemy_info[enemy][0]:
			var current_room = room_que[0]
			var coord = spawn_by_room[current_room[0]].pop_front()
			if coord == null:
				continue
			room_que[0][1]+= 1
			room_que.sort_custom(CustomSorter,"priority_sorter")
			spawn_info[enemy].append(coord)
	return spawn_info


func spawn_pass(spawn_info,tile_map,entities):
	for enemy in spawn_info:
		for spawn in spawn_info[enemy]:
			var test = enemy_info[enemy][1].instance()
			var pos = tile_map.map_to_world(spawn)
			test.global_position = tile_map.to_global(pos)
			#test.global_position -= Vector2(2,2)
			entities.add_child(test)


func gen_dijstra_map(start,path):
	var d_map = {}
	var que = []
	d_map[start] = 0
	que.push_back(start)
	while(que.size()>0):
		var curr = que.pop_front()
		var candidates = [
			Vector2(curr.x+1,curr.y),
			Vector2(curr.x-1,curr.y),
			Vector2(curr.x,curr.y+1),
			Vector2(curr.x,curr.y-1)
		]
		for candidate in candidates:
			if candidate in d_map or not candidate in path:
				continue
			d_map[candidate] = d_map[curr]+1
			que.push_back(candidate)
	return d_map


static func _randomize_rooms(room_list):
	var room_que = []
	#room_que = [[room,value],[room,value],..]
	for room in room_list:
		room_que.append([room,randi()])
	room_que.sort_custom(CustomSorter,"priority_sorter")
	for room in room_que:
		room[1] = 0
	return room_que


class CustomSorter:
	static  func priority_sorter(a,b):
		if a[1] < b[1]:
			return true
		return false
