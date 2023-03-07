extends Node
onready var Floor = get_node("%Floor")
onready var Walls:TileMap = get_node("%Walls")

export(bool) var debug_mode = false 

export(Vector2) var map_size = Vector2(60,60) 
var filler:PCG_TileFiller
var level = []


########################################################################
#WALKER Params
########################################################################
var walker:PCG_Walker
enum CARDINAL_DIR{N,S,E,W}

export(int) var corridor_width = 3
export(int) var walk_length = 500
export(Vector2) var walker_start_pos = Vector2(0,0)
export(CARDINAL_DIR) var start_direction = CARDINAL_DIR.S
export(float) var random_turn_chance = 0.25
export(int) var max_steps_in_direction = 2


########################################################################
#PARTIONER Params
########################################################################
var the_British:PCG_Partioner



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
	walker.construct(map_size,corridor_width)
	
	var path = walker.random_walk(walk_length,walker_start_pos,start_direction,random_turn_chance,max_steps_in_direction)
	filler.floor_pass(path,level,Floor)
	filler.wall_pass(path,level,Walls)
