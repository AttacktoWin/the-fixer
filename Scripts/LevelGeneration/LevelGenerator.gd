extends Node2D

export(int) var room_count: int = 5
export(Vector2) var min_dims: Vector2 = Vector2(5, 5)  # 5,5
export(Vector2) var max_dims: Vector2 = Vector2(8, 8)  # 8,8
export(int) var seperation_strength = 4
export(int) var enemies_per_room = 3

var saved_seed
var rng = RandomNumberGenerator.new()
var level = []  #-1 = non, 1 = floor, 2 = wall
var test_enemy = load("res://Scenes/Enemies/E_Goomba.tscn")

#DEBUG
var test_rooms = []
var test_points = []


func _ready():
	self.rng.randomize()

	var room_maker = PCG_Rooms.new(self.room_count, self.min_dims, self.max_dims, self.rng)
	var rooms = room_maker.spawn_rooms(seperation_strength)

	var connector = PCG_Connector.new()
	var corridors = connector._connect_rooms(rooms)

	var builder = PCG_Level.new($"%Floor", $"%Walls", rng)
	builder.build_level(rooms, corridors, self.level)

	var spawner = PCG_Spawner.new(
		$"%Floor",
		$"../SortableEntities/Runtime",
		$"../SortableEntities/Player",
		$"../Transition",
		rng
	)
	spawner.spawn_content(rooms, enemies_per_room, test_enemy)
	self.test_rooms = rooms


#DEBUG
func _draw():
	for room in self.test_rooms:
		draw_rect(room, Color(0, 1, 0, 1), false, 2)
	var current = self.test_rooms[0]
	for i in self.test_rooms.size():
		draw_line(current.get_center(), self.test_rooms[i].get_center(), Color(1, 1, 1, 1), 2)
		current = self.test_rooms[i]
	for point in test_points:
		draw_circle(point, 3, Color(0, 0, 1, 1))


################
################


class PCG_Rooms:
	var room_count
	var min_dims: Vector2
	var max_dims: Vector2
	var rng: RandomNumberGenerator
	var left_edge_buffer = 3
	const MAX_PUSH = 500

	func _init(_count, _min_dims, _max_dims, _rng):
		self.room_count = _count
		self.min_dims = _min_dims
		self.max_dims = _max_dims
		self.rng = _rng

	func spawn_rooms(step_size) -> Array:
		var rooms = []
		_spawn_rects(rooms)
		_seperate(rooms, step_size)
		return _order_room(rooms)

	func _spawn_rects(o_list: Array) -> void:
		for i in self.room_count:
			var room = Rect2(
				Vector2(5, 5),
				Vector2(
					self.rng.randi_range(self.min_dims.x, self.max_dims.x),
					self.rng.randi_range(self.min_dims.y, self.max_dims.y)
				)
			)
			o_list.append(room)

	func _seperate(o_list: Array, step_size) -> void:
		var security_count = 0
		while _is_overlapping(o_list) and security_count < MAX_PUSH:
			security_count += 1
			for current in room_count:
				for other in room_count:
					if current == other or not o_list[current].intersects(o_list[other], true):
						continue
					var move_vec = o_list[current].get_center() - o_list[other].get_center()
					if move_vec==Vector2.ZERO and security_count==0:
						print("pain")
					if move_vec.x > 0:
						o_list[current].position.x = clamp(
							o_list[current].position.x + step_size, left_edge_buffer, INF
						)
						o_list[other].position.x = clamp(
							o_list[other].position.x - step_size, left_edge_buffer, INF
						)
					if move_vec.y > 0:
						o_list[current].position.y = clamp(
							o_list[current].position.y + step_size, left_edge_buffer, INF
						)
						o_list[other].position.y = clamp(
							o_list[other].position.y - step_size, left_edge_buffer, INF
						)
		if(security_count==MAX_PUSH):
			print("premature,exit")

	func _is_overlapping(o_list: Array) -> bool:
		for current in o_list:
			for other in o_list:
				if current != other and current.intersects(other, true):
					return true
		return false

	func _order_room(rooms):
		var current = rooms.pop_at(0)
		var sorted = [current]
		while rooms.size() > 0:
			current = rooms.pop_at(_closest_room(current, rooms))
			sorted.append(current)
		return sorted

	func _closest_room(current: Rect2, rooms) -> int:
		var best_index = 0
		var min_dist = INF
		for i in rooms.size():
			var dist = current.get_center().distance_squared_to(rooms[i].get_center())
			if dist < min_dist:
				min_dist = dist
				best_index = i
		return best_index


################
################


class PCG_Connector:
	func _connect_rooms(rooms: Array) -> Array:
		var corridor_nodes = []
		var current = 0
		for next in range(1, rooms.size()):
			corridor_nodes += _build_corridor(
				rooms[current].get_center().floor(), rooms[next].get_center().floor()
			)
			current = next
			next += 1
		
		corridor_nodes += _build_corridor(
				rooms[0].get_center().floor(), rooms[rooms.size()-1].get_center().floor()
			)
		return corridor_nodes

	func _build_corridor(current: Vector2, end: Vector2) -> Array:
		var corridor = []
		while current != end:
			if current.x < end.x:
				current.x += 1
			elif current.x > end.x:
				current.x -= 1
			elif current.y < end.y:
				current.y += 1
			elif current.y > end.y:
				current.y -= 1
			for i in 2:
				for j in 2:
					corridor.push_back(current + Vector2(i, j))
		return corridor


################
################


class PCG_Level:
	var VENT_TILE = 6
	var floor_tileset: TileMap
	var wall_tileset: TileMap
	var rng: RandomNumberGenerator

	func _init(_floor, _wall, _rng):
		self.floor_tileset = _floor
		self.wall_tileset = _wall
		self.rng = _rng

	func build_level(rooms, corridors, level_array):
		var tile_by_room = {}
		var bounds = _get_bounding(rooms)
		_initalize_level_array(bounds,level_array)
		_build_floor(rooms, tile_by_room, level_array)
		_build_corridor(corridors, level_array)
		_build_wall(level_array, bounds)
		return tile_by_room

	func _get_bounding(rooms) -> Rect2:
		var bounds = Rect2(Vector2(0, 0), Vector2(0, 0))
		for room in rooms:
			if bounds.end.x < room.end.x:
				bounds.end.x = room.end.x
			if bounds.end.y < room.end.y:
				bounds.end.y = room.end.y
		bounds.end += Vector2.ONE
		return bounds
	
	func _initalize_level_array(bounds,o_list):
		for x in bounds.end.x:
			o_list.append([])
			for y in bounds.end.y:
				o_list[x].append(-1)
	
	func _build_floor(rooms, o_set, o_list):
		var pillar_count = 0
		for room in rooms:
			o_set[room] = []
			for x in range(room.position.x, room.end.x):
				for y in range(room.position.y, room.end.y):
					o_list[x][y] = 1
					o_set[room].append(Vector2(x, y))
					self.floor_tileset.set_cellv(Vector2(x, y), 0)

	func _build_corridor(corridor_points, o_list):
		for step in corridor_points:
			o_list[step.x][step.y] = 1
			self.floor_tileset.set_cellv(step, 0)

	#rng.randi_range(0,10)
	func _build_wall(o_list, _bounds):
		var kernel = [
			Vector2(0, 1),
			Vector2(0, -1),
			Vector2(1, 0),
			Vector2(-1, 0),
			Vector2(1, 1),
			Vector2(-1, -1),
			Vector2(-1, 1),
			Vector2(1, -1)
		]
		for x in _bounds.size.x:
			for y in _bounds.size.y:
				if o_list[x][y] == 1:
					continue
				for dir in kernel:
					var check = Vector2(
						clamp(x + dir.x, 0, _bounds.size.x - 1),
						clamp(y + dir.y, 0, _bounds.size.y - 1)
					)
					if o_list[check.x][check.y] == 1:
						self.wall_tileset.set_cellv(Vector2(x, y), rng.randi_range(2, 4))
						o_list[x][y] = 2
						break


################
################


class PCG_Spawner:
	var tile_map: TileMap
	var containter
	var player
	var transition
	var rng: RandomNumberGenerator
	var guns = [
		preload("res://Scenes/Weapons/PlayerShotgunScene.tscn").instance(),
		preload("res://Scenes/Weapons/PlayerTommyGunScene.tscn").instance(),
	]

	func _init(_floor, _containter, _player, _transition, _rng):
		self.tile_map = _floor
		self.containter = _containter
		self.transition = _transition
		self.player = _player
		self.rng = _rng

	func spawn_content(_rooms, n, enemy):
		set_start_end(_rooms)
		_spawn_weapon(_rooms)
		var spawn_points = []
		var rooms = _rooms.duplicate(true)
		rooms.pop_at(0)
		_sample(rooms, n, spawn_points)
		_spawn(enemy, spawn_points)

	func set_start_end(rooms):
		var start = _2tile2iso(rooms[0].get_center())
		var end = _2tile2iso(rooms[rooms.size() - 1].get_center())
		self.player.position = start
		self.transition.position = end

	func _spawn_weapon(rooms):
		var max_dist = 0
		var best_index = 0
		var current = rooms[0].get_center()
		for i in rooms.size() - 1:
			var dist = current.distance_squared_to(rooms[i].get_center())
			if dist > max_dist:
				max_dist = dist
				best_index = i
		var instance = WorldWeapon.new()
		instance.set_weapon(self.guns[rng.randi_range(0, self.guns.size() - 1)])
		instance.position = _2tile2iso(rooms[best_index].get_center())
		instance.auto_pickup = false
		self.containter.add_child(instance)

	#fibbonaci sampling
	func _sample(rooms, n, o_points):
		for room in rooms:
			var radius = pow((min(room.size.x, room.size.y) / 2) - 1, 2)
			var center = room.get_center()
			for _i in range(n):
				var theta = self.rng.randf() * 2 * PI
				var r = sqrt(self.rng.randi_range(0, radius))
				o_points.append(Vector2(r * cos(theta), r * sin(theta)) + center)
		print("POINTS SAMPLED: ",o_points.size())

	#peremeter sampling
	func _sample2(rooms, n, o_points):
		for room in rooms:
			var center = room.get_center()
			var radius = (min(room.size.x, room.size.y) / 2) - 1
			for i in range(n):
				var theta = 2 * PI * i / n
				var x = center.x + radius * cos(theta)
				var y = center.y + radius * sin(theta)
				o_points.append(Vector2(x, y))
		print("POINTS SAMPLED: ",o_points.size())

	func _spawn(enemy, points):
		for point in points:
			var instance = enemy.instance()
			instance.position = _2tile2iso(point)
			self.containter.add_child(instance)

	func _2tile2iso(coord: Vector2):
		var spawn = self.tile_map.map_to_world(coord)
		return MathUtils.to_iso(self.tile_map.to_global(spawn))
