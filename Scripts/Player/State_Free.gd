class_name PlayerState_Free extends Base_State

const TURN_FACTOR = 2


func on_enter(_msg: Dictionary = {}) -> void:
	.on_enter(_msg)


func _ground_control(delta_fixed):
	# general rule:
	# if the angle you're going is < 120 degrees from the one you're trying to go to, turn
	# otherwise, stop in x frames and turn

	var wanted_dir = state_machine._get_wanted_direction()

	var current_vel = state_machine._getv(LivingEntity.VARIABLE.VELOCITY)

	var diff = wanted_dir.angle_to(current_vel)
	if wanted_dir.x == 0 and wanted_dir.y == 0:
		diff = PI * 2

	# handle the case where we are stopped currently
	if abs(current_vel.x) < 25 and abs(current_vel.y) < 25:
		var boost = 6 * delta_fixed
		var wanted_vel = state_machine._get_wanted_velocity()
		var speed_diff = wanted_vel.length() - current_vel.length()
		var accel = state_machine._getv(LivingEntity.VARIABLE.ACCEL) * boost
		var max_spd = state_machine._getv(LivingEntity.VARIABLE.MAX_SPEED)
		var new_vel = wanted_dir * clamp(clamp(speed_diff, -accel, accel), -max_spd, max_spd)
		state_machine._setv(LivingEntity.VARIABLE.VELOCITY, new_vel)
	elif abs(diff) <= PI / 1.5:
		var angle = current_vel.angle() - diff / TURN_FACTOR
		# first, turn
		current_vel = Vector2(cos(angle), sin(angle)) * current_vel.length()
		# now scale up the speed to the desired one (using dot prod)
		var wanted_vel = state_machine._get_wanted_velocity()
		var coeff = wanted_vel.normalized().dot(current_vel.normalized())
		var speed_diff = wanted_vel.length() - current_vel.length()
		var dir = current_vel.normalized()
		var accel = state_machine._getv(LivingEntity.VARIABLE.ACCEL) * delta_fixed
		var change = dir * clamp(speed_diff, -accel, accel) * coeff
		state_machine._setv(LivingEntity.VARIABLE.VELOCITY, current_vel + change)
	else:
		state_machine._setv(LivingEntity.VARIABLE.VELOCITY, current_vel / 2)


func tick(_delta: float) -> void:
	pass


func physics_tick(_delta: float) -> void:
	var delta_fixed = _delta * 60
	self._ground_control(delta_fixed)

	if state_machine._getv(LivingEntity.VARIABLE.VELOCITY).length() > 25:
		if state_machine.animator.get_current_node() != "Walk":
			state_machine.animator.travel("Walk")
	else:
		if state_machine.animator.get_current_node() != "Idle":
			state_machine.animator.travel("Idle")
