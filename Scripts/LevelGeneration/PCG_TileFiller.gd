class_name PCG_TileFiller
extends Node

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


# Description: Fills teh floor in tileset
func floor_pass(
	path,			#param: path generated by walker
	level,			#param: level file containg data rep of the level
	floor_set,		#param: floor tile set tile set that is being written to
	caller=null		#param: will print one tile per frame if caller is provided. For debuging
	):
	for step in path:
		if level[step.x][step.y] == -1:
			floor_set.set_cellv(Vector2(step.x,step.y),1)
			level[step.x][step.y] = 1


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
				wall_set.set_cellv(Vector2(curr.x,curr.y),2)
				level[curr.x][curr.y] == 2
