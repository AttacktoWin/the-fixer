class_name Player extends MovingEntity

const TURN_FACTOR = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	yield(owner, "ready")
	var gun = TestGun.new()
	gun.set_parent(self)
	get_tree().get_root().call_deferred("add_child", gun)


func _get_wanted_direction():
	var dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if dir.length() > 1:
		return dir.normalized()
	return dir


func _get_wanted_velocity():
	return _get_wanted_direction() * _getv(VARIABLE.MAX_SPEED)


func _state_finished():
	if self._state == STATE.DASHING:
		var v = _getv(VARIABLE.VELOCITY)
		if v.x == 0 and v.y == 0:
			set_state(STATE.IDLE)
		else:
			set_state(STATE.MOVING)


# TODO: use delta!!!


func _ground_control(delta_fixed):
	# general rule:
	# if the angle you're going is < 120 degrees from the one you're trying to go to, turn
	# otherwise, stop in x frames and turn
	var wanted_dir = _get_wanted_direction()

	var current_vel = _getv(VARIABLE.VELOCITY)

	var diff = wanted_dir.angle_to(current_vel)
	if wanted_dir.x == 0 and wanted_dir.y == 0:
		diff = PI * 2

	# handle the case where we are stopped currently
	if abs(current_vel.x) < 25 and abs(current_vel.y) < 25:
		var boost = 6 * delta_fixed
		var wanted_vel = _get_wanted_velocity()
		var speed_diff = wanted_vel.length() - current_vel.length()
		var accel = _getv(VARIABLE.ACCEL) * boost
		var max_spd = _getv(VARIABLE.MAX_SPEED)
		var new_vel = wanted_dir * clamp(clamp(speed_diff, -accel, accel), -max_spd, max_spd)
		_setv(VARIABLE.VELOCITY, new_vel)
	elif abs(diff) <= PI / 1.5:
		var angle = current_vel.angle() - diff / TURN_FACTOR
		# first, turn
		current_vel = Vector2(cos(angle), sin(angle)) * current_vel.length()
		# now scale up the speed to the desired one (using dot prod)
		var wanted_vel = _get_wanted_velocity()
		var coeff = wanted_vel.normalized().dot(current_vel.normalized())
		var speed_diff = wanted_vel.length() - current_vel.length()
		var dir = current_vel.normalized()
		var accel = _getv(VARIABLE.ACCEL) * delta_fixed
		var change = dir * clamp(speed_diff, -accel, accel) * coeff
		_setv(VARIABLE.VELOCITY, current_vel + change)
	else:
		_setv(VARIABLE.VELOCITY, current_vel / 3)


func _dash_surface(delta_fixed):
	pass


func _stun(delta_fixed):
	var current_vel = _getv(VARIABLE.VELOCITY)
	_setv(VARIABLE.VELOCITY, current_vel / 1.1)


func _apply_drag(delta_fixed):
	_setv(VARIABLE.VELOCITY, _getv(VARIABLE.VELOCITY) * _getv(VARIABLE.DRAG) / delta_fixed)


func _move_control(delta):
	var delta_fixed = delta * 60
	match self._state:
		STATE.IDLE:
			self._ground_control(delta_fixed)
		STATE.MOVING:
			self._ground_control(delta_fixed)
		# no player control
		STATE.DASHING:
			self._dash_surface(delta_fixed)
		STATE.HITSTUN:
			self._stun(delta_fixed)
		_:
			self._apply_drag(delta_fixed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if PausingSingleton.is_paused():
			PausingSingleton.unpause(self)
		else:
			PausingSingleton.pause(self)


func _physics_process(delta):
	self._move_control(delta)
	self._try_move()

	var off = CameraSingleton.get_mouse_from_camera_center() / 15
	CameraSingleton.set_target_center(self.position + off)
