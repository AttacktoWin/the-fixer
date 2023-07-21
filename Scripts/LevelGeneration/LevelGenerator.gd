extends Node2D

export(NodePath) var Player_path
export(NodePath) var Exit_path
onready var player = (
	get_node(Player_path)
	if Player_path
	else get_node("../SortableEntities/Player")
)
onready var exit = get_node(Exit_path)

export(NodePath) var parent
onready var entities: Node2D = get_node(parent)
export(int) var enemies_per_room = 5
export(int) var enemy_buffer = 2
export(int) var pillbug_spawn_rate = 40
export(int) var spyder_spawn_rate = 25
export(int) var beetle_spawn_rate = 15
export(int) var ant_spawn_rate = 10
export(int) var bird_spawn_rate = 10
export(int) var rooms = 3

export(Resource) var generator_data = PCG_RoomData.new()

onready var Floor = get_node("%Floor")
onready var Walls: TileMap = get_node("%Walls")

enum MODE { ROOM, WALKED_ROOM }
enum CARDINAL_DIR { N, S, E, W }
var rng = RandomNumberGenerator.new()
var level = []  #-1 = non, 1 = floor, 2 = wall
var saved_seed

const MAX_TRIES = 5000


func _init():
	var rand = randi()
	rng.seed = rand
	self.saved_seed = rand


func _ready():
	try_build_level()


func try_build_level():
	initialize_level(generator_data)

	var attempts = 0
	while not build_level() and attempts < MAX_TRIES:
		attempts += 1

	if attempts > 500:
		print("WARN: Attempts to generate level > 500!!! (", attempts, ") TRY DIFFERENT SETTINGS")
	elif attempts > 250:
		print(
			"WARN: Attempts to generate level > 250! (",
			attempts,
			") You should not be seeing this unless your settings are very strict"
		)
	elif attempts > 50:
		print(
			"WARN: Attempts to generate level > 50 (",
			attempts,
			") If you are seeing this often, try different settings."
		)

	assert(
		attempts < MAX_TRIES,
		"Failed to generate full level within 1000 attempts! Try different parameters"
	)


func build_level():
	Floor.clear()
	Walls.clear()
	var path = []
	var room_list = []
	var room_centers = []
	var path_by_rooms = {}
	var enemy_info = {
		"pillbug": [pillbug_spawn_rate, load("res://Scenes/Enemies/E_Goomba.tscn")],
		"spyder": [spyder_spawn_rate, load("res://Scenes/Enemies/E_Spyder.tscn")],
		"beetle": [beetle_spawn_rate, load("res://Scenes/Enemies/E_Beetle.tscn")],
		"ant": [ant_spawn_rate, load("res://Scenes/Enemies/E_Ant.tscn")],
		"bird": [bird_spawn_rate, load("res://Scenes/Enemies/E_Umbrella.tscn")]
	}

	#initlize level array
	var level_space = Rect2(0, 0, generator_data.map_size.x, generator_data.map_size.y)
	#declare building too,
	var partitioner = PCG_Partioner.new()
	var corridor_builder = PCG_Corridors.new()
	var populator = PCG_Populator.new()
	var filler = PCG_TileFiller.new()

	#initialize level building tools
	partitioner.construct(
		rng,
		level_space,
		generator_data.min_width,
		generator_data.min_height,
		generator_data.shrink_factor
	)
	corridor_builder.construct(rng, generator_data.corridor_width)
	populator.construct(rng, player, exit, enemies_per_room, enemy_buffer, enemy_info)
	filler.construct(rng)

	var attempts = 0

	match generator_data.mode:
		MODE.ROOM:
			#simple room based builder
			while room_list.size() != self.rooms and attempts < MAX_TRIES:
				path.clear()
				path_by_rooms.clear()
				room_list.clear()
				room_centers.clear()

				partitioner.room_builder(path, path_by_rooms, room_list, room_centers)
				attempts += 1

			assert(
				room_list.size() == self.rooms,
				"Unable to generate dungeon in 1000 tries! Try different parameters"
			)

			path += corridor_builder.connect_rooms(room_centers)
		MODE.WALKED_ROOM:
			#builder with room based random walk for more organic looking rooms
			var walker = PCG_Walker.new()
			walker.construct(rng.seed)

			while room_list.size() != self.rooms and attempts < MAX_TRIES:
				room_list.clear()
				partitioner.binary_space_partition(
					generator_data.min_width, generator_data.min_height, level_space, room_list
				)
				attempts += 1

			assert(
				room_list.size() == self.rooms,
				"Unable to generate dungeon in 1000 tries! Try different parameters"
			)

			room_centers = partitioner.get_centers(room_list)
			path = corridor_builder.connect_rooms(room_centers)
			var build_data = walker.random_walk_room(
				generator_data, path, path_by_rooms, room_list, room_centers
			)
			path = build_data[0]
			path_by_rooms = build_data[1]

	if attempts > 500:
		print("WARN: Attempts to generate dungeon > 500!!! (", attempts, ") TRY DIFFERENT SETTINGS")
	elif attempts > 250:
		print(
			"WARN: Attempts to generate dungeon > 250! (",
			attempts,
			") You should not be seeing this unless your settings are very strict"
		)
	elif attempts > 50:
		print(
			"WARN: Attempts to generate dungeon > 50 (",
			attempts,
			") If you are seeing this often, try different settings."
		)

	var end_index = populator.populate(Floor, path, path_by_rooms, room_list, room_centers)

	if end_index == -1:
		return false

	self.level = filler.floor_pass(path, level, Floor)
	filler.room_deco_pass(room_list, path_by_rooms, Floor)
	self.level = filler.wall_pass(path, level, Walls)

	# perform one last check... everything must be on a floor tile!
	return populator.validate(self.level, entities)


func initialize_level(data):
	for x in range(0, data.map_size.x + 1):
		self.level.push_back([])
		for _y in range(0, data.map_size.y + 1):
			self.level[x].push_back(-1)


func set_seed(value):
	rng.seed = value
	self.saved_seed = value


func get_seed():
	return self.saved_seed
