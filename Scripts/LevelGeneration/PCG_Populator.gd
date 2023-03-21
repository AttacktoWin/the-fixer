class_name PCG_Populator
extends Node2D

var player
var goal

func construct(_player,_goal):
	self.player = _player
	self.goal = _goal
	
func populate(tile_map,path,room_list,room_centers,path_by_room):
	_player_goal_pass(tile_map,path,room_list,room_centers,path_by_room)
	_pick_cast()

func _player_goal_pass(tile_map,path,room_list,room_centers,path_by_room):
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
			#flatten space around center
			for x in range (-3,4):
				for y in range (-3,4):
					path.push_back(room_centers[index]+Vector2(x,y))
			#set room center as exit
			pos = tile_map.map_to_world(room_centers[index])
			goal.global_position = tile_map.to_global(pos)
			break


func _pick_cast():
	var enemies = ["goomba","bird","camera"]
	var value = [5,6,8]
	var cost = [2,5,6]
	var budget = 10
	#lets solve a knapsack problem baby
	#look up table first
	var look_up = []
	for item in range(enemies.size()+1):
		look_up.append([])
		for capcity in range(budget+1):
			look_up[item].append(0)
	
	var n = value.size()
	for i in range(1,n+1):
		for j in range(1,budget+1):
			if cost[i-1]<=j:
				look_up[i][j] = max(look_up[i-1][j], look_up[i-1][j-cost[i-1]]+value[i-1])
			else:
				look_up[i][j] = look_up[i-1][j]
	
	var i = n
	var j = budget
	var selection = []
	while i>0 and j>0:
		if look_up[i][j] != look_up[i-1][j]:
			selection.append(enemies[i-1])
			j-=cost[i-1]
		i-=1
	
	print(look_up)
#	      0  1  2  3  4  5  6  7  8  9 10
#      ----------------------------------
#    0 |  0  0  0  0  0  0  0  0  0  0  0
#    1 |  0  0  5  5 10 10 15 15 20 20 25
#    2 |  0  0  5  5 10 10 15 15 20 20 25
#    3 |  0  0  5  5 10 10 15 15 20 20 25

func _hostile_pass():
	pass
	# reverse priority que of all rooms start with equal weight, shuffled and exluding start
	# for each enemy:
		#take the top room
		#pick a random place it
		#pop immediate neighbours
		#if room has no more valid nodes kill it from the list
		#otherwise add to it the cost


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
