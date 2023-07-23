# Author: Marcus

class_name PlayerStateFree extends FSMNode

var t_timer = 0
var dash_timer = 0


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.IDLE, PlayerState.MOVING]


func enter():
	pass


func exit():
	self.entity.arms_secondary.hide()
	self.entity.arms_container.scale.x = 0.5
	self.fsm.get_animation_player().playback_speed = 1.0


func _physics_process(delta):
	self.dash_timer -= delta
	self._ground_control(MathUtils.delta_frames(delta))
	if Input.is_action_pressed("weapon_fire_melee") and self.entity.has_melee():
		self.fsm.set_state(PlayerState.FIRE_MELEE)


func _background_physics(delta):
	self.dash_timer -= delta


func _process(_delta):
	if self.t_timer > 0:
		self.t_timer -= _delta
		self.entity.set_gun_angle(0)
		self.entity.arms_secondary.show()
		self.entity.arms_container.scale.x = -0.5
	else:
		self.entity.arms_secondary.hide()
		self.entity.arms_container.scale.x = 0.5
		self.entity.player_input_gun_aim()

	var vel = self.entity.getv(LivingEntityVariable.VELOCITY)
	if vel.length() > 25 or self.entity.get_wanted_direction().length() > 0.1:
		self.fsm.set_animation("WALK")
		var x = sign(round(vel.x))

		var facing = sign(self.entity.get_wanted_gun_vector().x)
		var speed = (
			vel.length()
			/ self.entity.variables.get_variable_raw(LivingEntityVariable.MAX_SPEED)
		)
		if x != 0 and x != facing:
			speed = -speed
		self.fsm.get_animation_player().playback_speed = speed
	else:
		self.fsm.set_animation("IDLE")
		self.fsm.get_animation_player().playback_speed = 1

	if self.dash_timer > 0 and self.fsm.can_transition_to(PlayerState.DASHING):
		self.dash_timer = 0
		self.fsm.set_state(PlayerState.DASHING)


func _input(event):
	if not self.fsm.is_this_state(self) and event.is_action("move_dash"):
		self.dash_timer = 0.2


func _unhandled_input(event: InputEvent):
	if PausingSingleton.is_paused_recently(6) or not self.fsm.is_this_state(self):
		return

	if event.is_action_pressed("move_dash"):
		self.dash_timer = 0.2
		if self.fsm.can_transition_to(PlayerState.DASHING):
			self.dash_timer = 0
			self.fsm.set_state(PlayerState.DASHING)

	if (
		event is InputEventKey
		and event.scancode == KEY_T
		and not event.is_echo()
		and event.is_pressed()
		and randf() < 0.1 # :)
	):
		CameraSingleton.shake(20)
		self.t_timer = 0.1


const TURN_FACTOR = 2


func _ground_control(delta_fixed):
	# general rule:
	# if the angle you're going is < 120 degrees from the one you're trying to go to, turn
	# otherwise, stop in x frames and turn

	var wanted_dir = self.entity.get_wanted_direction()

	var current_vel = self.entity.getv(LivingEntityVariable.VELOCITY)

	var diff = wanted_dir.angle_to(current_vel)
	if wanted_dir.x == 0 and wanted_dir.y == 0:
		diff = PI * 2

	# handle the case where we are stopped currently
	if abs(current_vel.x) < 25 and abs(current_vel.y) < 25:
		var boost = 6 * delta_fixed
		var wanted_vel = self.entity.get_input_velocity()
		var speed_diff = wanted_vel.length() - current_vel.length()
		var accel = self.entity.getv(LivingEntityVariable.ACCEL) * boost
		var max_spd = self.entity.getv(LivingEntityVariable.MAX_SPEED)
		var new_vel = wanted_dir * clamp(clamp(speed_diff, -accel, accel), -max_spd, max_spd)
		self.entity.setv(LivingEntityVariable.VELOCITY, new_vel)
	elif abs(diff) <= PI / 1.5:
		var angle = current_vel.angle() - diff / TURN_FACTOR
		# first, turn
		current_vel = Vector2(cos(angle), sin(angle)) * current_vel.length()
		# now scale up the speed to the desired one (using dot prod)
		var wanted_vel = self.entity.get_input_velocity()
		var coeff = wanted_vel.normalized().dot(current_vel.normalized())
		var speed_diff = wanted_vel.length() - current_vel.length()
		var dir = current_vel.normalized()
		var accel = self.entity.getv(LivingEntityVariable.ACCEL) * delta_fixed
		var change = dir * clamp(speed_diff, -accel, accel) * coeff
		self.entity.setv(LivingEntityVariable.VELOCITY, current_vel + change)
	else:
		self.entity.setv(LivingEntityVariable.VELOCITY, current_vel / 2)
