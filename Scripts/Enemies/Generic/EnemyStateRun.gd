# Author: Marcus

class_name EnemyStateRun extends EnemyStateMoving

export var draw_path: bool = false
export var max_run_distance: float = 1024
var _path: PathfindResult = null
var _has_found_path = false
var _attempts = 0

const MAX_ATTETMPS = 10


func get_handled_states():
	return [EnemyState.RUNNING]


func enter():
	self.entity.disable_pathfind += 1
	self._attempts = 0
	self._has_found_path = false
	self._path = null


func exit():
	self.entity.disable_pathfind -= 1


func _follow_path(delta):
	if self._path == null:
		_try_move(delta, Vector2())
		return
	self._path.update(self.entity.global_position)
	var dir = self.entity.apply_steering(self._path.get_target_vector())
	var vel = self.entity.get_wanted_velocity(dir)
	_try_move(delta, vel)
	if self._path.is_path_complete():
		self._path = null


func _try_find_path():
	var angle = (self.entity.global_position - self.entity.get_target().global_position).angle()
	var attempts = 100
	self._attempts += 1
	self._path = null
	while self._path == null and attempts > 0:
		var angle2 = angle + randf() * PI / 2 - PI / 4
		if self._attempts > MAX_ATTETMPS:
			angle2 = randf() * PI * 2
		var dist = randf() * max_run_distance
		var loc = self.entity.global_position + Vector2(cos(angle2) * dist, sin(angle2) * dist)
		if Pathfinder.is_in_bounds(loc):
			self._path = Pathfinder.generate_path(self.entity.global_position, loc)
		attempts -= 1
	return self._path != null


func _physics_process(delta):
	self._update_visuals()
	if not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return
	if not self._has_found_path:
		self._has_found_path = _try_find_path()
	else:
		_follow_path(delta)
		if self._path == null:
			self.fsm.set_state(EnemyState.IDLE)


func _process(_delta):
	update()


func _draw():
	if self._path and self.draw_path:
		self._path.draw(self)
