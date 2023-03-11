extends Node2D
onready var Floor = get_node("%Floor")
onready var Walls:TileMap = get_node("%Walls")

export(Vector2) var map_size = Vector2(60,60) 

var level = []

########################################################################
#WALKER Params
########################################################################
var walker:PCG_Walker
enum CARDINAL_DIR{N,S,E,W}

export(int) var walk_length = 500
export(Vector2) var walker_start_pos = Vector2(0,0)
export(CARDINAL_DIR) var start_direction = CARDINAL_DIR.S
export(float) var random_turn_chance = 0.25
export(int) var max_steps_in_direction = 2


########################################################################
#PARTIONER Params
########################################################################
var partitioner:PCG_Partioner


########################################################################
#CORRIDOR_BUILDER Params
########################################################################
export(int) var corridor_width = 3
var corridor_builder:PCG_Corridors


########################################################################
#TILE_FILLER Params
########################################################################
var filler:PCG_TileFiller

func _init():
	#initlize level array
	#its so cursed that there isnt a better way to initialize a 2d array
	for x in range (0,map_size.x*2):
		level.push_back([])
		for _y in range (0,map_size.y*2):
			level[x].push_back(-1)

func _ready():
	filler	= PCG_TileFiller.new()
	walker	= PCG_Walker.new()
	partitioner = PCG_Partioner.new()
	corridor_builder = PCG_Corridors.new()
	
	var level_space = Rect2(0,0,map_size.x,map_size.y)
	
	var path = walker.random_walk(
		walk_length,
		walker_start_pos,
		start_direction,
		random_turn_chance,max_steps_in_direction)
	
	level = filler.floor_pass(path,level,Floor)
	level = filler.wall_pass(path,level,Walls)
	
#	var partitioning_data = partitioner.room_builder()
#	var path2 = partitioning_data[0]
#	path2+=corridor_builder.connect_rooms(partitioning_data[1])
#	filler.floor_pass(path2,level,Floor)
#	filler.wall_pass(path2,level,Walls)
