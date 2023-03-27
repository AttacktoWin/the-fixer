class_name PCG_TileFiller
extends Node
# Author: Yalmaz
# Description: 

enum {N,S,E,W,NE,NW,SE,SW}
var neighbours_kernel = {
	N:Vector2(0,1),
	S:Vector2(0,-1),
	E:Vector2(1,0),
	W:Vector2(-1,0),
	
	NE:Vector2(1,1),
	NW:Vector2(-1,1),
	SE:Vector2(1,-1),
	SW:Vector2(-1,-1),
}

var random:RandomNumberGenerator
func construct(rng):
	random = rng
	
# Description: Fills teh floor in tileset
func floor_pass(
	path,			#param: path generated by walker
	level,			#param: level file containg data rep of the level
	floor_set		#param: floor tile set tile set that is being written to
	):
	for step in path:
		if level[step.x][step.y] == -1:
			floor_set.set_cellv(Vector2(step.x,step.y),random.randi_range(0,10))
			level[step.x][step.y] = 1
	return level

func room_deco_pass(path,room_list,path_by_rooms,end_index,floor_set):
	var room_tiles = room_list.duplicate()
	var start_room = room_tiles.pop_at(0)
	for tile in path_by_rooms[start_room]:
		floor_set.set_cellv(Vector2(tile.x,tile.y),6)
	
	for room in room_tiles:
		for tile in path_by_rooms[room]:
			var is_edge = false
			for neighbour in neighbours_kernel:
				var curr = tile+neighbours_kernel[neighbour]
				if not(curr in path_by_rooms[room]):
					is_edge = true
					break
			if is_edge:
				floor_set.set_cellv(tile,6)
	
	room_tiles.remove(end_index)
	room_tiles.shuffle()
	var random_deco_tile = random.randi_range(6,10)
	for tile in path_by_rooms[room_tiles[0]]:
		floor_set.set_cellv(Vector2(tile.x,tile.y),random_deco_tile)

# Description: Fills the walls in tileset
func wall_pass(
	path,			#param: path generated by walker
	level,			#param: level file containg data rep of the level
	wall_set		#param: wall tile set that is being written to
	):
	var processed = {}
	for step in path:
		for neighbour in neighbours_kernel:
			var curr = Vector2(
				step.x-neighbours_kernel[neighbour].x,
				step.y-neighbours_kernel[neighbour].y)
			if(
				processed.get(curr) == null 
				and level[curr.x][curr.y] == -1
			):
				level[curr.x][curr.y] = 2
				wall_set.set_cellv(Vector2(curr.x,curr.y),random.randi_range(2,4))
	return level
