# Author: Marcus

class_name UmbrellaStateIdle extends EnemyStateWander

var _last_angle: float = 0
const ANGLE_MOVE: float = PI / 3


func enter():
	self._last_angle = randf() * PI * 2
	.enter()


func _generate_random_path():
	if (self.entity.global_position - self._home).length() > self.wander_radius * 2:
		return ._generate_random_path()

	var radius2 = self.wander_radius * 0.5

	var attempts = 10
	self._path = null
	while self._path == null and attempts > 0:
		var angle = randf() * PI / 8 + self._last_angle
		var dist = (
			(randf() + self.min_wander_distance_fac)
			/ (1 + self.min_wander_distance_fac)
			* radius2
		)
		var loc = self.entity.global_position + Vector2(cos(angle) * dist, sin(angle) * dist)
		if Pathfinder.is_in_bounds(loc):
			self._path = Pathfinder.generate_path(self.entity.global_position, loc)
			if self._path.path_length() > radius2 * 2:
				self._path = null
		attempts -= 1
	self._last_angle += (randf() + 1) / 2 * ANGLE_MOVE
	return self._path != null


func _update_visuals():
	if _is_moving():
		self.fsm.set_animation("FLY_CLOSED")
	else:
		self.fsm.set_animation("IDLE_CLOSED")

	var vel = self.entity.getv(LivingEntityVariable.VELOCITY)
	var x = -sign(vel.x)
	if x != 0:
		self.entity.flip_components.scale.x = x


func target_set(_target: LivingEntity):
	self.fsm.set_state(EnemyState.ALERTED)


func investigate_target_set(target: Vector2):
	if self.fsm.is_this_state(self):
		self._home = target
		self._path = Pathfinder.generate_path(self.entity.global_position, target)
