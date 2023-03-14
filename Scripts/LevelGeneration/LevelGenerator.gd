extends Node2D
onready var Floor = get_node("%Floor")
onready var Walls:TileMap = get_node("%Walls")

var level = []
enum MODE{WALK,ROOM,WALKED_ROOM}
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

func _init():
	#initlize level array
	#its so cursed that there isnt a better way to initialize a 2d array
	for x in range (0,map_size.x+1):
		level.push_back([])
		for _y in range (0,map_size.y+1):
			level[x].push_back(-1)

func _ready():
	filler	= PCG_TileFiller.new()
	walker	= PCG_Walker.new()
	partitioner = PCG_Partioner.new()
	corridor_builder = PCG_Corridors.new()
	
	var level_space = Rect2(0,0,map_size.x,map_size.y)
	
	match generator_mode:
		MODE.WALK:
			var path = walker.random_walk(
				level_space,
				self.walker_start_pos,
				self.start_direction,
				self.walk_length,
				self.random_turn_chance,self.max_steps_in_direction)
			filler.floor_pass(path,level,Floor)
			self.level = filler.wall_pass(path,level,Walls)
		MODE.ROOM:
			var partitioning_data = partitioner.room_builder(
				level_space,
				self.room_min_width,
				self.room_min_height,
				self.room_space_between)
			var path = partitioning_data[0]
			var room_centers = partitioning_data[2]
			path+=corridor_builder.connect_rooms(room_centers,self.corridor_width)
			filler.floor_pass(path,level,Floor)
			self.level = filler.wall_pass(path,level,Walls)
		MODE.WALKED_ROOM:
			var partitioning_data = partitioner.binary_space_partition(
				level_space,
				self.room_min_width,self.room_min_height)
			var room_list = partitioning_data[0]
			var room_centers = partitioning_data[1]
			var path = []
			for index in room_list.size():
				print(index)
				var partial_path = walker.random_walk(
					room_list[index],
					room_centers[index],
					self.start_direction,
					self.walk_length,
					self.random_turn_chance,self.max_steps_in_direction)
				path+=partial_path
			path+=corridor_builder.connect_rooms(room_centers,self.corridor_width)
			filler.floor_pass(path,level,Floor)
			self.level = filler.wall_pass(path,level,Walls)
