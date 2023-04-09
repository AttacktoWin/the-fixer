extends Node2D
var level = []  #-1 = non, 1 = floor, 2 = wall
var saved_seed

const TILE_SIZE = 10

var room_count:int = 5
var min_dims:Vector2 = Vector2(100,100)
var max_dims:Vector2 = Vector2(500,500)
var rng = RandomNumberGenerator.new()

#DEBUG
var test_rooms = []
var _debug = true
func _ready():
	self.rng.randomize()
	self.test_rooms = _spawn_rects()

func _process(delta):
	var is_seperated =  _seperate(self.test_rooms)
	if is_seperated and _debug:
		_shrink(self.test_rooms)
		_debug = false
	update()

#DEBUG
func _draw():
	for room in self.test_rooms:
		draw_rect(room,Color(0,1,0,1),false,2)
	self.test_rooms = _order_room(self.test_rooms)
	var current = self.test_rooms[0]
	for i in self.test_rooms.size():
		draw_line(
			current.get_center(),
			self.test_rooms[i].get_center(),
			Color(1,1,1,1),
			3
		)
		current = self.test_rooms[i]

func _spawn_rects()->Array:
	var rooms = []
	for i in self.room_count:
		var room = Rect2(
			Vector2(712,300),
			Vector2(
				self.rng.randi_range(self.min_dims.x+TILE_SIZE,self.max_dims.x+TILE_SIZE),
				self.rng.randi_range(self.min_dims.y+TILE_SIZE,self.max_dims.y+TILE_SIZE)
				)
			)
		rooms.append(room)
	return rooms

func _seperate(rooms)->bool:
	if _is_overlapping(rooms):
		for current in room_count:
			for other in room_count:
				if current == other or not rooms[current].intersects(rooms[other],true):
					continue
				var move_vec = rooms[current].get_center() - rooms[other].get_center()
				print(move_vec)
				if move_vec.x>0:
					rooms[current].position.x = clamp(rooms[current].position.x+TILE_SIZE,0,INF)
					rooms[other].position.x = clamp(rooms[other].position.x-TILE_SIZE,0,INF)
				if move_vec.y>0:
					rooms[current].position.y = clamp(rooms[current].position.y+TILE_SIZE,0,INF)
					rooms[other].position.y = clamp(rooms[other].position.y-TILE_SIZE,0,INF)
		return false
	return true

func _is_overlapping(rooms:Array)->bool:
	for current in rooms:
		for other in rooms:
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

func _shrink(rooms):
	for i in rooms.size():
		rooms[i].size -= Vector2(TILE_SIZE,TILE_SIZE)
