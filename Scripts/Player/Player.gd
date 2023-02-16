class_name Player extends Base_AnimatedFSM

var _dash_timer = Timer.new()
var _dash_part = 1
var _dash_direction = Vector2()

var _inv_timer = 0

onready var anim_player: AnimationPlayer = $Visual/AnimationPlayer
onready var socket_muzzle: Node2D = $Visual/ArmsContainer/SocketMuzzle
onready var arms_container: Node2D = $Visual/ArmsContainer
onready var visual: Node2D = $Visual

var _gun = null


# Called when the node enters the scene tree for the first time.
func _ready():
	self._gun = TestGun.new()
	self._gun.set_parent(self)
	self._gun.set_aim_bone(arms_container)
	socket_muzzle.add_child(self._gun)
	self._dash_timer.one_shot = true
	self._dash_timer.connect("timeout", self, "_dash_increment")
	add_child(self._dash_timer)
	._ready()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("move_dash"):
		if self._dash_part == 1:
			# CameraSingleton.freeze(CameraSingleton.TARGET.LOCATION)
			self.animation_tree.state_machine.travel("Dash")
			CameraSingleton.set_zoom(Vector2(1.01, 1.01))
			self._dash_part = 0
			self._dash_direction = MathUtils.vector_to_iso_vector(
				CameraSingleton.get_mouse_from_camera_center().normalized()
			)

			self._dash_timer.wait_time = 0.25
			self._dash_timer.start()
			self._inv_timer = 60


func _get_wanted_direction():
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if dir.length() > 1:
		dir = dir.normalized()
	return dir * Vector2(1, 0.5)


func _get_wanted_velocity():
	return _get_wanted_direction() * _getv(LivingEntity.VARIABLE.MAX_SPEED)


func _dash_increment():
	self._dash_part = 1
	# CameraSingleton.unfreeze(CameraSingleton.TARGET.LOCATION)
	CameraSingleton.set_zoom(Vector2(0.97, 0.97))
	CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM)
	CameraSingleton.set_zoom(Vector2(1, 1))
	var _discard = move_and_slide(self._dash_direction * 9600)


# func _stun(delta_fixed):
# 	var current_vel = _getv(VARIABLE.VELOCITY)
# 	_setv(VARIABLE.VELOCITY, current_vel / 1.1)

# func _apply_drag(delta_fixed):
# 	_setv(VARIABLE.VELOCITY, _getv(VARIABLE.VELOCITY) * _getv(VARIABLE.DRAG) / delta_fixed)


func _handle_gun_aim():
	if self._is_dead:
		return
	var vec = CameraSingleton.get_absolute_mouse() - arms_container.global_position
	self.visual.scale.x = sign(vec.x) if vec.x != 0.0 else 1.0
	vec.x = abs(vec.x)
	var angle = vec.angle()
	self.arms_container.rotation = angle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		# if PausingSingleton.is_paused():
		# 	PausingSingleton.unpause(self)
		# else:
		# 	PausingSingleton.pause(self)
		# Scene.switch(Scene.Demo1.instance())
		pass
	# self.try_take_damage(1)
	self._handle_gun_aim()


func _physics_process(delta):
	var state = self.animation_tree.state_machine.get_current_node()

	if state == "Die":
		self._setv(LivingEntity.VARIABLE.VELOCITY, Vector2.ZERO)

	if state == "Idle" or state == "Walk" or state == "Run":
		var delta_fixed = delta * 60
		self._ground_control(delta_fixed)

		var vel = self._getv(LivingEntity.VARIABLE.VELOCITY)
		if vel.length() > 25:
			if self.animation_tree.state_machine.get_current_node() != "Walk":
				self.animation_tree.state_machine.travel("Walk")
		else:
			if self.animation_tree.state_machine.get_current_node() != "Idle":
				self.animation_tree.state_machine.travel("Idle")

	self._try_move()

	var center = CameraSingleton.get_mouse_from_camera_center() / 360
	var off = (
		MathUtils.interpolate_vector(
			Vector2(abs(center.x), abs(center.y)), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL
		)
		* Vector2(sign(center.x), sign(center.y))
	)
	var off2 = off + self._getv(VARIABLE.VELOCITY) / 8
	CameraSingleton.set_target_center(self.position + off2)


func _on_take_damage(_amount: float, _meta: HitMetadata):
	var bar = Scene.ui.get_node("HUD/HealthBar")
	bar.value = ((self._getv(LivingEntity.VARIABLE.HEALTH) / self.base_health) * 100)


func _on_death():
	self.animation_tree.state_machine.travel("Die")
	self._gun.queue_free()


# FSM


func on_Anim_change(_prev_state: String, _new_state: String):
	if _new_state == "Dash":
		self._setv(LivingEntity.VARIABLE.VELOCITY, Vector2.ZERO)


const TURN_FACTOR = 2


func _ground_control(delta_fixed):
	# general rule:
	# if the angle you're going is < 120 degrees from the one you're trying to go to, turn
	# otherwise, stop in x frames and turn

	var wanted_dir = self._get_wanted_direction()

	var current_vel = self._getv(LivingEntity.VARIABLE.VELOCITY)

	var diff = wanted_dir.angle_to(current_vel)
	if wanted_dir.x == 0 and wanted_dir.y == 0:
		diff = PI * 2

	# handle the case where we are stopped currently
	if abs(current_vel.x) < 25 and abs(current_vel.y) < 25:
		var boost = 6 * delta_fixed
		var wanted_vel = self._get_wanted_velocity()
		var speed_diff = wanted_vel.length() - current_vel.length()
		var accel = self._getv(LivingEntity.VARIABLE.ACCEL) * boost
		var max_spd = self._getv(LivingEntity.VARIABLE.MAX_SPEED)
		var new_vel = wanted_dir * clamp(clamp(speed_diff, -accel, accel), -max_spd, max_spd)
		self._setv(LivingEntity.VARIABLE.VELOCITY, new_vel)
	elif abs(diff) <= PI / 1.5:
		var angle = current_vel.angle() - diff / TURN_FACTOR
		# first, turn
		current_vel = Vector2(cos(angle), sin(angle)) * current_vel.length()
		# now scale up the speed to the desired one (using dot prod)
		var wanted_vel = self._get_wanted_velocity()
		var coeff = wanted_vel.normalized().dot(current_vel.normalized())
		var speed_diff = wanted_vel.length() - current_vel.length()
		var dir = current_vel.normalized()
		var accel = self._getv(LivingEntity.VARIABLE.ACCEL) * delta_fixed
		var change = dir * clamp(speed_diff, -accel, accel) * coeff
		self._setv(LivingEntity.VARIABLE.VELOCITY, current_vel + change)
	else:
		self._setv(LivingEntity.VARIABLE.VELOCITY, current_vel / 2)
