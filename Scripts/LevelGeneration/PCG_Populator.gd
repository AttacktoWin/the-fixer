class_name PCG_Populator
extends Node2D

export(PackedScene) onready var enemies
var player
var goal
var budget = 30

func construct(_player,_goal):
	self.player = _player
	self.goal = _goal
	
func populate(tile_map,path,room_list,room_centers,path_by_room):
	_player_goal_pass(tile_map,path,room_list,room_centers,path_by_room)

func _player_goal_pass(tile_map,path,room_list,room_centers,path_by_room):
	#i could just get start end from corridor builder?
	
	
	var centers = room_centers
	var start = centers.front()
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
			#flatten space around center
			for x in range (-3,4):
				for y in range (-3,4):
					path.push_back(room_centers[index]+Vector2(x,y))
			#set room center as exit
			pos = tile_map.map_to_world(room_centers[index])
			goal.global_position = tile_map.to_global(pos)
			break
	

func _pick_cast():
	var enemies = ["goomba","camera","bird"]
	var total =0
	while total<budget:
		pass
	# while budget not dry and budget not less then min cost:
		#while set>0
			#pick enemy from suffled set
			#if cost<budget
				#budget-cost
				#break
			#else
				#pop

func _hostile_pass():
	pass
	# find path to goal
		#dijkstra
		#test by spawning goombs
	# sample n=cast_size points on path at even distance
		#test by spawning enemy at each point should be even
	# reduce even-ness and translate it
	# offset the positioning
	
	#pesudo poisson appraoch:
	# divide cast among rooms
	#for each enemy in room
		# pick random point in room. delete cost radius

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
