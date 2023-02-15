class_name Player extends LivingEntity

var _dash_timer = Timer.new()
var _dash_part = 1
var _dash_direction = Vector2()

var _inv_timer = 0

onready var animator: AnimationNodeStateMachinePlayback = $Visual/AnimationTree.get(
	"parameters/playback"
)
onready var socket_muzzle: Node2D = $Visual/ArmsContainer/SocketMuzzle
onready var arms_container: Node2D = $Visual/ArmsContainer
onready var visual: Node2D = $Visual


# Called when the node enters the scene tree for the first time.
func _ready():
	var gun = TestGun.new()
	gun.set_parent(self)
	gun.set_aim_bone(arms_container)
	socket_muzzle.add_child(gun)
	self._dash_timer.one_shot = true
	self._dash_timer.connect("timeout", self, "_dash_increment")
	add_child(self._dash_timer)
	._ready()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("move_dash"):
		if self._dash_part == 1:
			# CameraSingleton.freeze(CameraSingleton.TARGET.LOCATION)
			self.transition_to("DASH")
			CameraSingleton.set_zoom(Vector2(1.01, 1.01))
			self._dash_part = 0
			self._dash_direction = CameraSingleton.get_mouse_from_camera_center().normalized()
			self._dash_timer.wait_time = 0.25
			self._dash_timer.start()
			self._inv_timer = 60


func _get_wanted_direction():
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if dir.length() > 1:
		return dir.normalized()
	return dir


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
	var vec = CameraSingleton.get_absolute_mouse() - arms_container.global_position
	self.visual.scale.x = sign(vec.x) if vec.x != 0.0 else 1.0
	vec.x = abs(vec.x)
	var angle = vec.angle()
	self.arms_container.rotation = angle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	._process(_delta)
	if Input.is_action_just_pressed("ui_accept"):
		if PausingSingleton.is_paused():
			PausingSingleton.unpause(self)
		else:
			PausingSingleton.pause(self)
	# self.try_take_damage(1)
	self._handle_gun_aim()


func _physics_process(delta):
	._physics_process(delta)

	# self._move_control(delta)
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
