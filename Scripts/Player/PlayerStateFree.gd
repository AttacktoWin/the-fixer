# Author: Marcus

class_name PlayerStateFree extends FSMNode


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.IDLE, PlayerState.MOVING]


func enter():
	pass


func exit():
	self.fsm.get_animation_player().playback_speed = 1.0


func _physics_process(_delta):
	var delta_fixed = _delta * 60
	self._ground_control(delta_fixed)


func _process(_delta):
	var vel = self.entity.getv(LivingEntity.VARIABLE.VELOCITY)
	if vel.length() > 25:
		self.fsm.set_animation("WALK")
	else:
		self.fsm.set_animation("IDLE")
	var x = sign(vel.x)
	var facing = sign(CameraSingleton.get_mouse_from_camera_center().x)
	if x != facing:
		self.fsm.get_animation_player().playback_speed = -1.0
	else:
		self.fsm.get_animation_player().playback_speed = 1.0


func _unhandled_input(event: InputEvent):
	if PausingSingleton.is_paused():
		return

	if event.is_action_pressed("move_dash") and self.fsm.is_this_state(self):
		self.fsm.set_state(PlayerState.DASHING)


const TURN_FACTOR = 2


func _ground_control(delta_fixed):
	# general rule:
	# if the angle you're going is < 120 degrees from the one you're trying to go to, turn
	# otherwise, stop in x frames and turn

	var wanted_dir = self.entity._get_wanted_direction()

	var current_vel = self.entity.getv(LivingEntity.VARIABLE.VELOCITY)

	var diff = wanted_dir.angle_to(current_vel)
	if wanted_dir.x == 0 and wanted_dir.y == 0:
		diff = PI * 2

	# handle the case where we are stopped currently
	if abs(current_vel.x) < 25 and abs(current_vel.y) < 25:
		var boost = 6 * delta_fixed
		var wanted_vel = self.entity._get_wanted_velocity()
		var speed_diff = wanted_vel.length() - current_vel.length()
		var accel = self.entity.getv(LivingEntity.VARIABLE.ACCEL) * boost
		var max_spd = self.entity.getv(LivingEntity.VARIABLE.MAX_SPEED)
		var new_vel = wanted_dir * clamp(clamp(speed_diff, -accel, accel), -max_spd, max_spd)
		self.entity.setv(LivingEntity.VARIABLE.VELOCITY, new_vel)
	elif abs(diff) <= PI / 1.5:
		var angle = current_vel.angle() - diff / TURN_FACTOR
		# first, turn
		current_vel = Vector2(cos(angle), sin(angle)) * current_vel.length()
		# now scale up the speed to the desired one (using dot prod)
		var wanted_vel = self.entity._get_wanted_velocity()
		var coeff = wanted_vel.normalized().dot(current_vel.normalized())
		var speed_diff = wanted_vel.length() - current_vel.length()
		var dir = current_vel.normalized()
		var accel = self.entity.getv(LivingEntity.VARIABLE.ACCEL) * delta_fixed
		var change = dir * clamp(speed_diff, -accel, accel) * coeff
		self.entity.setv(LivingEntity.VARIABLE.VELOCITY, current_vel + change)
	else:
		self.entity.setv(LivingEntity.VARIABLE.VELOCITY, current_vel / 2)
