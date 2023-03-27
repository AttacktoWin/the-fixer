# Author: Marcus

class_name Player extends LivingEntity

var _inv_timer = 0

onready var anim_player: AnimationPlayer = $Visual/AnimationPlayer
onready var socket_muzzle: Node2D = $Visual/ArmsContainer/SocketMuzzle
onready var arms_container: Node2D = $Visual/ArmsContainer
onready var arms_secondary: Node2D = $Visual/Arm2
onready var visual: Node2D = $Visual
onready var fsm: FSMController = $FSMController

var _gun = null

var gun_controlled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Wwise.register_listener(self)
	Wwise.register_game_obj(self, self.get_name())
	self._gun = TestGun.new(self)
	self._gun.set_aim_bone(arms_container)
	socket_muzzle.add_child(self._gun)


func _get_wanted_direction():
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if dir.length() > 1:
		dir = dir.normalized()
	return dir


func _get_wanted_velocity():
	return _get_wanted_direction() * getv(LivingEntityVariable.MAX_SPEED)


func get_wanted_gun_vector():
	return MathUtils.to_iso(CameraSingleton.get_absolute_mouse() - arms_container.global_position)


func set_gun_angle(angle):
	self.arms_container.rotation = angle


func player_input_gun_aim():
	if self._is_dead:
		return
	var vec = get_wanted_gun_vector()
	self.visual.scale.x = sign(vec.x) if vec.x != 0.0 else 1.0
	vec.x = abs(vec.x)
	var angle = vec.angle()
	self.set_gun_angle(angle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if OS.is_debug_build():
		if Input.is_action_pressed("ui_focus_next"):
			var enemy = load("res://Scenes/Enemies/E_Spyder.tscn").instance()
			enemy.global_position = CameraSingleton.get_absolute_mouse_iso()
			Scene.runtime.add_child(enemy)
		if Input.is_action_just_pressed("ui_up"):
			var start = MathUtils.to_level_vector(self.global_position)
			var end = MathUtils.to_level_vector(CameraSingleton.get_absolute_mouse())
			print(MathUtils.line_coords(start, end))
			for coord in MathUtils.line_coords(start, end):
				if Scene.level[coord.x][coord.y] == Constants.TILE_TYPE.WALL:
					print("Hit @ ", coord)
		if Input.is_action_just_pressed("ui_down"):
			var loc = MathUtils.floor_vec2(MathUtils.to_level_vector(self.global_position))
			print(Pathfinder._pathfinder.get_point_connections(loc.x + loc.y * Pathfinder._width))


func _unhandled_input(event: InputEvent):
	if (
		OS.is_debug_build()
		and event is InputEventKey
		and event.scancode == 96
		and not event.is_echo()
		and event.is_pressed()
	):
		if self.fsm.current_state_name() == PlayerState.DEV:
			self.fsm.set_state(PlayerState.IDLE)
		else:
			self.fsm.set_state(PlayerState.DEV)


func _handle_camera():
	var center = CameraSingleton.get_mouse_from_camera_center() / 360
	var off = (
		Vector2(
			MathUtils.interpolate(abs(center.x), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL),
			MathUtils.interpolate(abs(center.y), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL)
		)
		* Vector2(sign(center.x), sign(center.y))
	)
	var off2 = off + self.getv(LivingEntityVariable.VELOCITY) / 8
	CameraSingleton.set_target_center(self.position + off2)


func _physics_process(delta):
	# Wwise.set_2d_position(self, self.global_position)
	_handle_camera()
	_try_move()
	._physics_process(delta)


func _on_take_damage(_info: AttackInfo):
	var bar = Scene.ui.get_node("HUD/HealthBar")
	bar.value = ((getv(LivingEntityVariable.HEALTH) / self.base_health) * 100)


func _on_death():
	self.fsm.set_state(PlayerState.DEAD)
	self._gun.queue_free()
