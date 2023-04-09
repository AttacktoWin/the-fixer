# Author: Marcus

class_name PathfindResult extends Resource

var _path_steps: Array = []
var _path_index: int = 0
var _path_complete: bool = false
var _current_location: Vector2 = Vector2()

var _auto_advance: bool = true
var _advance_distance: float = 4


func _init(start: Vector2, nodes: Array = []):
	self._current_location = start
	self._path_steps = nodes


# if auto advance is set, the path will automatically advance when the location is near enough
func set_auto_advance(value: bool) -> void:
	self._auto_advance = value


# if auto advance is set, advance when you are less then this many units away
func set_advance_distance(distance: float) -> void:
	self._advance_distance = distance


func path_exists() -> bool:
	return self._path_steps.size() != 0


func update(position: Vector2, entity_radius: float = 0):
	# check if we are close enough to advance to the next part of our path
	self._current_location = position
	self._check_advance(entity_radius)


func _check_advance(entity_radius: float):
	if not self._auto_advance or self._path_complete:
		return
	if self._check_distance_to_next_node() - entity_radius < self._advance_distance:
		self.advance()


func advance() -> void:
	if self._path_index < self._path_steps.size() - 1:
		self._path_index += 1
	else:
		self._path_complete = true


func get_next_location() -> Vector2:
	if not path_exists():
		return self._current_location
	return self._path_steps[self._path_index]


func is_path_complete():
	return self._path_complete


func _check_distance_to_next_node() -> float:
	return (self._current_location - self.get_next_location()).length()


# returns a normalized vector representing the direction to move
func get_target_vector(from = null) -> Vector2:
	if not path_exists():
		return Vector2(0, 0)

	from = from if from else self._current_location
	var to = get_next_location()
	return (to - from).normalized()


func path_length() -> float:
	if self._path_complete:
		return 0.0

	var length = (self._current_location - self._path_steps[self._path_index]).length()
	for i in range(self._path_index, self._path_steps.size() - 1):
		length += (self._path_steps[i] - self._path_steps[i + 1]).length()

	return length


func draw(node: Node2D):
	#var transform = node.get_global_transform()
	#node.draw_set_transform_matrix(transform.inverse())

	for i in range(self._path_index, self._path_steps.size()):
		node.draw_circle(
			MathUtils.to_iso(self._path_steps[i] - node.global_position), 6, Color.white
		)
		if i < self._path_steps.size() - 1:
			node.draw_line(
				MathUtils.to_iso(self._path_steps[i] - node.global_position),
				MathUtils.to_iso(self._path_steps[i + 1] - node.global_position),
				Color.white,
				6
			)
	if self._path_steps.size() > 0:
		node.draw_line(
			MathUtils.to_iso(self._current_location - node.global_position),
			MathUtils.to_iso(self._path_steps[self._path_index] - node.global_position),
			Color.white,
			6
		)

	#node.draw_set_transform_matrix(transform)
