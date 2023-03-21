extends Node2D

export (NodePath) var Player_path
export (NodePath) var Exit_path
onready var player = get_node(Player_path)
onready var exit = get_node(Exit_path)

onready var Floor = get_node("%Floor")
onready var Walls:TileMap = get_node("%Walls")

var level = [] #-1 = non, 1 = floor, 2 = wall
enum MODE{ROOM,WALKED_ROOM}
enum CARDINAL_DIR{N,S,E,W}

export(Vector2) var map_size = Vector2(60,60) 
export(MODE) var generator_mode = MODE.WALKED_ROOM


# WALKER Params
var walker:PCG_Walker
var walker_start_pos = Vector2(0,0)

export(CARDINAL_DIR) var start_direction = CARDINAL_DIR.S
export(float) var random_turn_chance = 0.25
export(int) var walk_length = 500
export(int) var max_steps_in_direction = 2

# PARTIONER Params
var partitioner:PCG_Partioner
export(int) var room_min_width = 15
export(int) var room_min_height = 15
export(int) var room_space_between = 3

# CORRIDOR_BUILDER Params
var corridor_builder:PCG_Corridors
export(int) var corridor_width = 3

# TILE_FILLER Params
var filler:PCG_TileFiller

# POPULATOR Params
var populator:PCG_Populator


func _ready():
	#initlize level array
	#its so cursed that there isnt a better way to initialize a 2d array
	for x in range (0,map_size.x+1):
		level.push_back([])
		for _y in range (0,map_size.y+1):
			level[x].push_back(-1)
	var level_space = Rect2(0,0,map_size.x,map_size.y)
	
	# Initialize level building tools
	self.filler	= PCG_TileFiller.new()
	self.walker	= PCG_Walker.new()
	self.partitioner = PCG_Partioner.new()
	self.corridor_builder = PCG_Corridors.new()
	
	var path = []
	
	# Initialize level populator
	self.populator = PCG_Populator.new()
	self.populator.construct(player,exit)
	
	match generator_mode:
		MODE.ROOM:
			var building_data = partitioner.room_builder(
				level_space,
				self.room_min_width,
				self.room_min_height,
				self.room_space_between)
			path = building_data[0]
			var room_list = building_data[1]
			var room_centers = building_data[2]
			var path_by_rooms = building_data[3]
			path+=corridor_builder.connect_rooms(room_centers,self.corridor_width)
			populator.populate(Floor,path,room_list,room_centers,path_by_rooms)
		MODE.WALKED_ROOM:
			var partitioning_data = partitioner.binary_space_partition(
				level_space,
				self.room_min_width,self.room_min_height)
			var room_list = partitioning_data[0]
			var room_centers = partitioning_data[1]
			var path_by_rooms = {}
			path = corridor_builder.connect_rooms(room_centers,self.corridor_width)
			var build_data = random_walk_room(path,room_list,room_centers)
			path = build_data[0]
			path_by_rooms = build_data[1]
			populator.populate(Floor,path,room_list,room_centers,path_by_rooms)
	
	filler.floor_pass(path,level,Floor)
	self.level = filler.wall_pass(path,level,Walls)


# Uses the random walker in combination with room results to give walked rooms
func random_walk_room(path,room_list,room_centers):
	var path_by_rooms = {}
	for index in room_list.size():
		var partial_path = walker.random_walk(
			room_list[index],
			room_centers[index],
			self.start_direction,
			self.walk_length,
			self.random_turn_chance,self.max_steps_in_direction)
		path+=partial_path
		path_by_rooms[room_list[index]] = partial_path
	return [path,path_by_rooms]
