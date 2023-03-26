extends Node2D

export (NodePath) var Player_path
export (NodePath) var Exit_path
onready var player = get_node(Player_path)
onready var exit = get_node(Exit_path)

export(NodePath) var parent
onready var entities: Node2D = get_node(parent)
export(int) var enemies_per_room = 5
export(int) var enemy_buffer = 2
export(int) var pillbug_spawn_rate = 70
export(int) var spyder_spawn_rate = 30

export(Resource) var generator_data = PCG_RoomData.new()

onready var Floor = get_node("%Floor")
onready var Walls:TileMap = get_node("%Walls")

var level = [] #-1 = non, 1 = floor, 2 = wall
enum MODE{ROOM,WALKED_ROOM}
enum CARDINAL_DIR{N,S,E,W}
var walker_start_pos = Vector2(0,0)
var rng = RandomNumberGenerator.new()


func _init():
	rng.randomize()


func _ready():
	var path = []
	var room_list = []
	var room_centers = []
	var path_by_rooms = {}
	var enemy_info = {
		"pillbug": [pillbug_spawn_rate,load("res://Scenes/Enemies/E_Goomba.tscn")],
		"spyder": [spyder_spawn_rate,load("res://Scenes/Enemies/E_Spyder.tscn")]
	}
	
	#initlize level array
	initialize_level(generator_data)
	var level_space = Rect2(0,0,generator_data.map_size.x,generator_data.map_size.y)
	
	#declare building too,
	var partitioner = PCG_Partioner.new()
	var corridor_builder = PCG_Corridors.new()
	var populator = PCG_Populator.new()
	var filler	= PCG_TileFiller.new()
	
	#initialize level building tools
	partitioner.construct(
		rng,
		level_space,
		generator_data.min_width,generator_data.min_height,
		generator_data.shrink_factor)
	corridor_builder.construct(generator_data.corridor_width)
	populator.construct(player,exit,
	enemies_per_room,enemy_buffer,enemy_info)
	
	match generator_data.mode:
		MODE.ROOM:
			#simple room based builder
			partitioner.room_builder(
				path,
				path_by_rooms,
				room_list,
				room_centers)
			path += corridor_builder.connect_rooms(room_centers)
		MODE.WALKED_ROOM:
			#builder with room based random walk for more organic looking rooms
			var walker	= PCG_Walker.new()
			partitioner.binary_space_partition(
				generator_data.min_width,
				generator_data.min_height,
				level_space,room_list)
			room_centers = partitioner.get_centers(room_list)
			path = corridor_builder.connect_rooms(room_centers)
			var build_data = walker.random_walk_room(
				generator_data,
				path,path_by_rooms,
				room_list,room_centers)
			path = build_data[0]
			path_by_rooms = build_data[1]
	
	populator.populate(
		Floor,path,path_by_rooms,
		room_list,room_centers,
		entities)
	
	filler.floor_pass(path,level,Floor)
	self.level = filler.wall_pass(path,level,Walls)

func initialize_level(data):
	for x in range (0,data.map_size.x+1):
		self.level.push_back([])
		for _y in range (0,data.map_size.y+1):
			self.level[x].push_back(-1)
