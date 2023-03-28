# Author: Marcus

extends Node

var _pathfinder: AStar2D = null
var _width: int = -1
var _wall_gradient = null

const WALL_AVOID_DIST = 2
const WALL_AVOID_FAC = 1.25


func _neighbors(level, x, y):
	var n = []
	if x > 0:
		n.append(Vector2(x - 1, y))
	if x < level.size() - 1:
		n.append(Vector2(x + 1, y))
	if y > 0:
		n.append(Vector2(x, y - 1))
	if y < level[x].size() - 1:
		n.append(Vector2(x, y + 1))

	return n


func _calc_gradient(level, wall_distances, x, y):
	var gradient = Vector2()
	for xx in range(-1, 2):
		for yy in range(-1, 2):
			if x + xx > 0 and x + xx < level.size() and y + yy > 0 and y + yy < level[0].size():
				var diff = wall_distances[x + xx][y + yy] - wall_distances[x][y]
				gradient += Vector2(xx * diff, yy * diff)
	return gradient.normalized()


func _BFS_walls(level: Array, current: int = 1) -> Array:
	var open_set = []
	var temp_set = []
	# build open set
	for x in range(level.size()):
		for y in range(level[x].size()):
			if level[x][y] == current:
				open_set.append(Vector2(x, y))

	while open_set.size() > 0:
		for pos in open_set:
			for n in _neighbors(level, pos.x, pos.y):
				if level[n.x][n.y] == 0:
					level[n.x][n.y] = current + 1
					temp_set.append(n)
		open_set = temp_set
		temp_set = []
		current += 1

	return level


func _copy_array(level: Array):
	var arr = []
	for x in range(level.size()):
		var t = []
		for y in range(level[x].size()):
			t.append(level[x][y])
		arr.append(t)
	return arr


func _filter_number(level: Array, number: int) -> Array:
	level = _copy_array(level)
	for x in range(level.size()):
		for y in range(level[x].size()):
			level[x][y] = 1 if level[x][y] == number else 0
	return level


func _BFS_AStar(level: Array, x: int, y: int) -> void:
	var open_set = [Vector2(x, y)]
	var temp_set = []
	var seen = _filter_number(level, -100000)  # copy with all 0
	seen[x][y] = 1
	while open_set.size() > 0:
		for pos in open_set:
			seen[pos.x][pos.y] = 2
			for n in _neighbors(level, pos.x, pos.y):
				if level[n.x][n.y] == Constants.TILE_TYPE.FLOOR and seen[n.x][n.y] != 2:
					self._pathfinder.connect_points(
						pos.x + pos.y * self._width, n.x + n.y * self._width
					)
					if not seen[n.x][n.y]:
						temp_set.append(n)
					seen[n.x][n.y] = 1
		open_set = temp_set
		temp_set = []


func _build_AStar(level: Array, wall_distances: Array) -> void:
	var any_point = null
	for x in range(level.size()):
		for y in range(level[x].size()):
			if level[x][y] == Constants.TILE_TYPE.FLOOR:
				var wall_dist = WALL_AVOID_DIST - (wall_distances[x][y] - 1)
				var weight = 1.0
				if wall_dist >= 0:
					weight = pow(WALL_AVOID_FAC, wall_dist)
					self._wall_gradient[Vector2(x, y)] = (
						_calc_gradient(level, wall_distances, x, y)
						* weight
						/ pow(WALL_AVOID_FAC, 2)
					)
				var vec = MathUtils.from_level_vector(Vector2(x, y))

				vec.y += Constants.TILE.HYP / 2
				self._pathfinder.add_point(x + y * self._width, vec, weight)
				if any_point == null:
					any_point = Vector2(x, y)
	if any_point!=null:
		_BFS_AStar(level, any_point.x, any_point.y)


func update_level(new_level: Array):
	self._width = new_level.size()
	self._wall_gradient = {}
	self._pathfinder = AStar2D.new()
	var wall_distances = _BFS_walls(_filter_number(new_level, Constants.TILE_TYPE.WALL))
	_build_AStar(new_level, wall_distances)


func _simplify_path(start: Vector2, path: Array):
	var current = start
	var test = path[0]
	var last = test
	var new_path = []
	for x in range(path.size()):
		last = test
		test = path[x]
		if not AI.has_LOS(current, test):
			new_path.append(last)
			current = last
	if new_path.size() == 0 or test != new_path[new_path.size() - 1]:
		new_path.append(test)
	return new_path


# generates a path from one location to another
func generate_path(from: Vector2, to: Vector2) -> PathfindResult:
	var start = MathUtils.floor_vec2(MathUtils.to_level_vector(from))
	var end = MathUtils.floor_vec2(MathUtils.to_level_vector(to))
	if not is_in_bounds(from) or not is_in_bounds(to):
		return PathfindResult.new(from, [to])
	var data = self._pathfinder.get_point_path(
		start.x + start.y * self._width, end.x + end.y * self._width
	)
	data.append(to)
	return PathfindResult.new(from, _simplify_path(from, data))


func is_in_bounds(vec: Vector2) -> bool:
	vec = MathUtils.floor_vec2(MathUtils.to_level_vector(vec))
	var idx = vec.x + vec.y * self._width
	return self._pathfinder.has_point(idx)


func get_vector_from_walls(pos: Vector2) -> Vector2:
	var v = MathUtils.floor_vec2(MathUtils.to_level_vector(pos))
	return self._wall_gradient.get(v, Vector2())
