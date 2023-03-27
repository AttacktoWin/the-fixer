# Author: Marcus

class_name EnemyStateMoving extends FSMNode

var _animation_speed_multiplier: float = 1.0


func _is_moving():
	var vel = self.entity.getv(LivingEntity.VARIABLE.VELOCITY)
	return vel.length() > 1 or self.entity.get_wanted_direction().length() != 0


func _update_visuals():
	var vel = self.entity.getv(LivingEntity.VARIABLE.VELOCITY)
	if _is_moving():
		self.fsm.set_animation("CHASE")
	else:
		self.fsm.set_animation("IDLE")

	var x = -sign(vel.x)
	if x != 0:
		self.entity.flip_components.scale.x = x

	var speed = vel.length() / self.entity.getv(LivingEntity.VARIABLE.MAX_SPEED)

	if self.fsm.has_animation_player():
		if _is_moving():
			self.fsm.get_animation_player().playback_speed = (
				speed
				* self._animation_speed_multiplier
			)
		else:
			self.fsm.get_animation_player().playback_speed = 1


func _try_move(delta, wanted_velocity):
	var current_vel = self.entity.getv(LivingEntity.VARIABLE.VELOCITY)

	if not wanted_velocity:
		self.entity.setv(LivingEntity.VARIABLE.VELOCITY, current_vel / 1.25)
		if current_vel.length() < 20:
			self.entity.setv(LivingEntity.VARIABLE.VELOCITY, Vector2())
		self.entity._try_move()
		return

	var diff = wanted_velocity - current_vel
	var accel = diff * self.entity.getv(LivingEntity.VARIABLE.ACCEL) * delta
	if accel.length() > diff.length():
		self.entity.setv(LivingEntity.VARIABLE.VELOCITY, wanted_velocity)
	else:
		self.entity.setv(LivingEntity.VARIABLE.VELOCITY, current_vel + accel)
	self.entity._try_move()


func enter():
	pass


func exit():
	pass
