# Author: Marcus

class_name UmbrellaStateChase extends EnemyStateMoving

var _path: PathfindResult = null

const VARIANCE_MAX = PI / 4


func get_handled_states():
	return [EnemyState.CHASING]


func enter():
	self._path = null
	self.entity.disable_pathfind += 1
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, false)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_LINE_COLOR, Constants.COLOR.YELLOW)


func _update_visuals():
	if _is_moving():
		self.fsm.set_animation("FLY_OPEN")
	else:
		self.fsm.set_animation("IDLE_OPEN")

	var vel = self.entity.getv(LivingEntityVariable.VELOCITY)
	var x = -sign(vel.x)
	if x != 0:
		self.entity.flip_components.scale.x = x


func _generate_random_path():
	var from_target = self.entity.global_position - self.entity.get_target().global_position
	var angle = from_target.angle()

	var attempts = 10  # try at most 10 times to get the path...
	self._path = null
	while self._path == null and attempts > 0:
		var angle2 = angle + randf() * rand_range(-VARIANCE_MAX, VARIANCE_MAX)
		var dist = self.entity.ranged_attack_range * rand_range(0.5, 0.8)
		var loc = (
			self.entity.get_target().global_position
			+ Vector2(cos(angle2) * dist, sin(angle2) * dist)
		)
		if (
			Pathfinder.is_in_bounds(loc)
			and AI.has_LOS(self.entity.get_target().global_position, loc)
		):
			self._path = Pathfinder.generate_path(self.entity.global_position, loc)
			if self._path.path_length() > self.entity.ranged_attack_range * 2:
				self._path = null
		attempts -= 1
	return self._path != null


func _follow_path(delta):
	if self._path == null:
		_try_move(delta, Vector2())
		return
	self._path.update(self.entity.global_position, self.entity.entity_radius)
	var dir = self.entity.apply_steering(self._path.get_target_vector())
	var vel = self.entity.get_wanted_velocity(dir) * 2
	_try_move(delta, vel)
	if self._path.is_path_complete():
		self._path = null


func _physics_process(delta):
	if not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return

	if (
		AI.has_LOS(self.entity.global_position, self.entity.get_target().global_position)
		and (
			(self.entity.global_position - self.entity.get_target().global_position).length()
			< self.entity.ranged_attack_range
		)
	):
		self.fsm.set_state(EnemyState.ATTACKING_RANGED)
		return

	if not self._path:
		_generate_random_path()

	_follow_path(delta)
	_update_visuals()


func _exit():
	self.entity.disable_pathfind -= 1


func _draw():
	if self.entity.get_nav_path():
		self.entity.get_nav_path().draw(self)
