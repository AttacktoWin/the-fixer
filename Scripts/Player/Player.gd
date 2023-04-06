# Author: Marcus

class_name Player extends LivingEntity

var _inv_timer = 0

export(PackedScene) var start_weapon = null

onready var anim_player: AnimationPlayer = $Visual/AnimationPlayer
onready var arms_container: Node2D = $Visual/ArmsContainer
onready var hand: Node2D = $Visual/ArmsContainer/Hand
onready var arms_secondary: Node2D = $Visual/Arm2
onready var visual: Node2D = $Visual
onready var fsm: FSMController = $FSMController
onready var reload_progress_bar: ProgressBar = $ReloadProgress
onready var melee_hitbox: Area2D = $Visual/HitBox

var weapon_disabled = false setget set_weapon_disabled

var _gun = null
var _has_default_gun = false

var _knockback_velocity = Vector2.ZERO

const INVULNERABLE_TIME = 1

const HIT_SCENE = preload("res://Scenes/Particles/PlayerHitScene.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Wwise.register_listener(self)
	Wwise.register_game_obj(self, self.get_name())
	Scene.connect("world_updated", self, "_world_updated")  # warning-ignore:return_value_discarded


func _world_updated():
	if not self._has_default_gun:
		self._has_default_gun = true
		if start_weapon:
			self.set_gun(start_weapon.instance())
	CameraSingleton.jump_field(CameraSingleton.TARGET.LOCATION)


func set_weapon_disabled(val):
	weapon_disabled = val
	if self._gun:
		self._gun.set_disabled(val)


func set_gun(gun: PlayerBaseGun):
	if self._gun:
		var pickup = WorldWeapon.new()
		pickup.set_weapon(self._gun)
		pickup.auto_pickup = false
		pickup.global_position = self.global_position * MathUtils.TO_ISO
		Scene.runtime.add_child(pickup)
	self._gun = gun.with_parent(self)
	self._gun.set_aim_bone(arms_container)
	self.hand.add_child(self._gun.with_visuals(self._gun.default_visual_scene()))
	update_ammo_counter()


func has_gun() -> bool:
	return self._gun != null


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
	var v = MathUtils.to_iso(CameraSingleton.get_absolute_mouse() - arms_container.global_position)
	if self.weapon_disabled or not self._gun:
		return Vector2(
			(
				0.1 * sign(v.x) * max(abs(getv(LivingEntityVariable.VELOCITY).x) / 120, 1)
				if v.x != 0.0
				else 1.0
			),
			1
		)
	return v


func update_ammo_counter():
	var ammo_count = Scene.ui.get_node("HUD/AmmoCount")
	ammo_count.text = String(self._gun.get_ammo_count()) + "/" + String(self._gun.get_max_ammo())


func add_ammo(ammo: int):
	if self._gun:
		if self._gun.add_ammo(ammo):
			Wwise.post_event_id(AK.EVENTS.AMMO_PICKUP_PLAYER, self)
		update_ammo_counter()


func get_ammo() -> int:
	if self._gun:
		return self._gun.get_ammo_count()
	return 0


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


func _update_reload_progress():
	var progress = 1.0
	if self._gun:
		progress = self._gun.get_cooldown_percent()

	if progress >= 1.0:
		self.reload_progress_bar.visible = false
	else:
		self.reload_progress_bar.value = progress
		self.reload_progress_bar.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_update_reload_progress()
	if OS.is_debug_build():
		if Input.is_action_just_pressed("ui_focus_next"):
			var enemy = load("res://Scenes/Enemies/E_Umbrella.tscn").instance()
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
		if Input.is_action_just_pressed("ui_right"):
			var vec = MathUtils.floor_vec2(
				MathUtils.to_level_vector(CameraSingleton.get_absolute_mouse())
			)
			var idx = vec.x + vec.y * Pathfinder._width
			var point = Pathfinder._pathfinder.has_point(idx)
			var type = Scene.level[vec.x][vec.y]
			print("Level: ", vec, " -- in bounds: ", point, " -- tile_type: ", type)
		if Input.is_action_just_pressed("ui_left"):
			print("Playing test sound")
			Wwise.post_event_id(AK.EVENTS.ATTACK_PILLBUG, self)
		if Input.is_action_just_pressed("ui_end"):
			self.add_ammo(900)
		if Input.is_action_just_pressed("ui_home"):
			var scene = load("res://Scenes/Levels/BossRoom.tscn").instance()
			TransitionHelper.transition(scene)
		if Input.is_action_just_pressed("ui_page_down"):
			for enemy in AI.get_all_enemies():
				enemy.queue_free()


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


func _try_move():
	# warning-ignore:return_value_discarded
	move_and_slide(getv(LivingEntityVariable.VELOCITY) + self._knockback_velocity)


func _physics_process(delta):
	# Wwise.set_2d_position(self, self.global_position)
	self._knockback_velocity *= 0.93
	if self._knockback_velocity.length() < 30:
		self._knockback_velocity = Vector2.ZERO
	_handle_camera()
	_try_move()
	._physics_process(delta)


func knockback(vel: Vector2):
	self._knockback_velocity += vel


func update_health_bar():
	var bar = Scene.ui.get_node("HUD/HealthBar")
	bar.value = ((getv(LivingEntityVariable.HEALTH) / self.base_health) * 100)


func _on_take_damage(info: AttackInfo):
	var direction = info.get_attack_direction(self.global_position)
	knockback(
		(
			direction
			* info.knockback_factor
			* self.getv(LivingEntityVariable.KNOCKBACK_FACTOR)
			/ self.getv(LivingEntityVariable.WEIGHT)
		)
	)
	var fx = HIT_SCENE.instance()
	fx.initialize(direction.angle() + PI, info.damage)
	self.add_child(fx)
	fx.position = Vector2(0, -40)
	fx.scale = Vector2.ONE / 2
	self.status_timers.set_timer(LivingEntityStatus.INVULNERABLE, INVULNERABLE_TIME)
	update_health_bar()
	Scene.ui.get_node("DamageFeedback").display_feedback()
	._on_take_damage(info)


func _on_death():
	self._knockback_velocity = Vector2.ZERO
	self.fsm.set_state(PlayerState.DEAD, true)
	self.fsm.lock()
	if self._gun:
		self._gun.queue_free()
	self._gun = null
	StatsTracker.add_death()
