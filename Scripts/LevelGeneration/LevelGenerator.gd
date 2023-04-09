extends Node2D
var level = []  #-1 = non, 1 = floor, 2 = wall
var saved_seed

const TILE_SIZE = 2

var room_count:int = 7
var min_dims:Vector2 = Vector2(5,5)# 5,5
var max_dims:Vector2 = Vector2(8,8)#11,11
var rng = RandomNumberGenerator.new()

#DEBUG
var test_rooms = []
func _ready():
	var builder = PCG_Builder.new(
		self.room_count,
		self.min_dims,
		self.max_dims,
		self.rng
	)
	self.rng.randomize()
	var rooms = builder.build_rooms(TILE_SIZE)
	
	var connector = PCG_Connector.new()
	var corridors = connector._connect_rooms(rooms)
	var filler = PCG_Filler.new(
		$"%Floor",
		$"%Walls",
		rng
	)
	self.level = filler.fill_floor(rooms,corridors)
	self.test_rooms = rooms

func _process(delta):
	#update()
	pass

#DEBUG
func _draw():
	for room in self.test_rooms:
		draw_rect(room,Color(0,1,0,1),false,5)
	var current = self.test_rooms[0]
	for i in self.test_rooms.size():
		draw_line(
			current.get_center(),
			self.test_rooms[i].get_center(),
			Color(1,1,1,1),
			6
		)
		current = self.test_rooms[i]

func _shrink(rooms):
	for i in rooms.size():
		rooms[i].size -= Vector2(TILE_SIZE,TILE_SIZE)

class PCG_Builder:
	var room_count
	var min_dims:Vector2
	var max_dims:Vector2
	var rng:RandomNumberGenerator
	var left_edge_buffer = 3
	
	func _init(_count,_min_dims,_max_dims,_rng):
		self.room_count = _count
		self.min_dims = _min_dims
		self.max_dims = _max_dims
		self.rng = _rng
	
	func build_rooms(step_size)->Array:
		var rooms = []
		_spawn_rects(rooms)
		_seperate(rooms,step_size)
		return _order_room(rooms)
	
	func _spawn_rects(o_list:Array)->void:
		for i in self.room_count:
			var room = Rect2(
				Vector2(5,5),
				Vector2(
					self.rng.randi_range(self.min_dims.x,self.max_dims.x),
					self.rng.randi_range(self.min_dims.y,self.max_dims.y)
					)
				)
			o_list.append(room)
	
	func _seperate(o_list:Array,step_size)->void:
		while _is_overlapping(o_list):
			for current in room_count:
				for other in room_count:
					if current == other or not o_list[current].intersects(o_list[other],true):
						continue
					var move_vec = o_list[current].get_center() - o_list[other].get_center()
					if move_vec.x>0:
						o_list[current].position.x = clamp(
							o_list[current].position.x+step_size,
							left_edge_buffer,INF)
						o_list[other].position.x = clamp(
							o_list[other].position.x-step_size,
							left_edge_buffer,INF)
					
					if move_vec.y>0:
						o_list[current].position.y = clamp(
							o_list[current].position.y+step_size,
							left_edge_buffer,INF)
						o_list[other].position.y = clamp(
							o_list[other].position.y-step_size,
							left_edge_buffer,INF)
	
	func _is_overlapping(o_list:Array)->bool:
		for current in o_list:
			for other in o_list:
				if current != other and current.intersects(other,true):
					return true
		return false
	
	func _order_room(rooms):
		var current = rooms.pop_at(0)
		var sorted = [current]
		while rooms.size()>0:
			current = rooms.pop_at(_closest_room(current,rooms))
			sorted.append(current)
		return sorted
	
	func _closest_room(current:Rect2,rooms)->int:
		var best_index = 0
		var min_dist = INF
		for i in rooms.size():
			var dist = current.get_center().distance_squared_to(rooms[i].get_center())
			if dist<min_dist:
				min_dist = dist
				best_index = i
		return best_index

class PCG_Connector:
	func _connect_rooms(rooms:Array)->Array:
		var corridor_nodes = []
		var current = 0
		for next in range(1,rooms.size()):
			corridor_nodes += _build_corridor(
				rooms[current].get_center().floor(),
				rooms[next].get_center().floor()
			)
			current = next
			next += 1
		return corridor_nodes

	func _build_corridor(current:Vector2,end:Vector2)->Array:
		var corridor = []
		while(current!=end):
			if current.x < end.x:
				current.x += 1
			elif current.x > end.x:
				current.x -= 1
			elif current.y<end.y:
				current.y += 1
			elif current.y>end.y:
				current.y -= 1
			for i in 2:
				for j in 2:
					corridor.push_back(current+Vector2(i,j))
		return corridor

class PCG_Filler:
	var VENT_TILE = 6
	var floor_tileset:TileMap
	var wall_tileset:TileMap
	var rng:RandomNumberGenerator
	
	func _init(_floor,_wall,_rng):
		self.floor_tileset = _floor
		self.wall_tileset = _wall
		self.rng = _rng
	
	func fill_floor(rooms,corridors):
		var floor_set = {}
		var level_array = []
		var bounds = _get_bounding(rooms)
		_build_level(bounds,rooms,floor_set,level_array)
		_fill_corridor(corridors,floor_set,level_array)
		_fill_wall(level_array,bounds)
		return level_array
	
	func _get_bounding(rooms)->Rect2:
		var bounds = Rect2(Vector2(0,0),Vector2(0,0))
		for room in rooms:
			if bounds.end.x<room.end.x:
				bounds.end.x = room.end.x
			if bounds.end.y<room.end.y:
				bounds.end.y = room.end.y
		bounds.end+=Vector2.ONE
		return bounds
	
	func _build_level(bounds,rooms,o_set,o_list):
		for x in bounds.end.x:
			o_list.append([])
			for y in bounds.end.y:
				o_list[x].append(-1)
		for room in rooms:
			for x in range(room.position.x,room.end.x):
				for y in range(room.position.y,room.end.y):
					o_list[x][y] = 1
					o_set[Vector2(x,y)] = 1
					self.floor_tileset.set_cellv(Vector2(x,y),rng.randi_range(0,10))
	
	func _fill_corridor(corridor_points,o_set,o_list):
		for step in corridor_points:
			o_list[step.x][step.y] = 1
			o_set[step] = 1
			self.floor_tileset.set_cellv(step,rng.randi_range(0,10))
	
	func _fill_wall(o_list,_bounds):
		var kernel = [
			Vector2(0,1),
			Vector2(0,-1),
			Vector2(1,0),
			Vector2(-1,0),
			Vector2(1,1),
			Vector2(-1,-1),
			Vector2(-1,1),
			Vector2(1,-1)]
		for x in _bounds.size.x:
			for y in _bounds.size.y:
				if o_list[x][y] == 1:
					continue
				for dir in kernel:
					var check = Vector2(
						clamp(x+dir.x,0,_bounds.size.x-1),
						clamp(y+dir.y,0,_bounds.size.y-1))
					if o_list[check.x][check.y] == 1:
						self.wall_tileset.set_cellv(Vector2(x,y),rng.randi_range(2,4))
						o_list[x][y] = 2
						break
