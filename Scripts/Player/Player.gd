class_name Player extends LivingEntity

var _inv_timer = 0

onready var anim_player: AnimationPlayer = $Visual/AnimationPlayer
onready var socket_muzzle: Node2D = $Visual/ArmsContainer/SocketMuzzle
onready var arms_container: Node2D = $Visual/ArmsContainer
onready var visual: Node2D = $Visual
onready var fsm: FSMController = $FSMController

var _gun = null


func _init():
	Wwise.register_listener(self)
	Wwise.register_game_obj(self, self.get_name())


# Called when the node enters the scene tree for the first time.
func _ready():
	self._gun = TestGun.new()
	self._gun.set_parent(self)
	self._gun.set_aim_bone(arms_container)
	socket_muzzle.add_child(self._gun)


func _get_wanted_direction():
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if dir.length() > 1:
		dir = dir.normalized()
	return dir * Vector2(1, 0.5)


func _get_wanted_velocity():
	return _get_wanted_direction() * getv(LivingEntity.VARIABLE.MAX_SPEED)


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
	self._handle_gun_aim()


func _handle_camera():
	var center = CameraSingleton.get_mouse_from_camera_center() / 360
	var off = (
		MathUtils.interpolate_vector(
			Vector2(abs(center.x), abs(center.y)), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL
		)
		* Vector2(sign(center.x), sign(center.y))
	)
	var off2 = off + self.getv(VARIABLE.VELOCITY) / 8
	CameraSingleton.set_target_center(self.position + off2)


func _physics_process(_delta):
	# Wwise.set_2d_position(self, self.global_position)
	_handle_camera()
	_try_move()


func _on_take_damage(_amount: float, _meta: HitMetadata):
	var bar = Scene.ui.get_node("HUD/HealthBar")
	bar.value = ((getv(LivingEntity.VARIABLE.HEALTH) / self.base_health) * 100)


func _on_death():
	self.fsm.set_state(PlayerState.DEAD)
	self._gun.queue_free()
