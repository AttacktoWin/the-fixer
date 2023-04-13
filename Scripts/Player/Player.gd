# Author: Marcus

class_name Player extends LivingEntity

var _inv_timer = 0

export(PackedScene) var start_gun = null
export(PackedScene) var start_melee = null

onready var anim_player: AnimationPlayer = $Visual/AnimationPlayer
onready var arms_container: Node2D = $Visual/ArmsContainer
onready var hand: Node2D = $Visual/ArmsContainer/Hand
onready var melee_hand: Node2D = $Visual/MeleeHand
onready var arms_secondary: Node2D = $Visual/Arm2
onready var visual: Node2D = $Visual
onready var fsm: FSMController = $FSMController
onready var reload_progress_bar: ProgressBar = $ReloadProgress
onready var melee_hitbox: BaseAttack = $Visual/HitBox
onready var flash_node: Node2D = $FlashNode

var upgrades_applied = false

var weapon_disabled = false setget set_weapon_disabled

var _gun = null
var _melee = null
var _has_default_weapons = false

var _knockback_velocity = Vector2.ZERO

const INVULNERABLE_TIME = 1

const HIT_SCENE = preload("res://Scenes/Particles/PlayerHitScene.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Wwise.register_game_obj(self, self.get_name())
	Scene.connect("world_updated", self, "_world_updated")  # warning-ignore:return_value_discarded
	# move flash into limbo
	self.flash_node.get_parent().remove_child(self.flash_node)
	StatsSingleton.apply_upgrades(self)


func _world_updated():
	if not self._has_default_weapons:
		self._has_default_weapons = true
		if start_gun and not has_gun():
			self.set_gun(start_gun.instance())
		if start_melee and not has_melee():
			self.set_melee(start_melee.instance())
	CameraSingleton.jump_field(CameraSingleton.TARGET.LOCATION)


func save():
	var data = {}
	data["HEALTH"] = getv(LivingEntityVariable.HEALTH)
	data["AMMO"] = self._gun.ammo_count if self._gun else 0
	return data


func load_data(data: Dictionary):
	setv(LivingEntityVariable.HEALTH, data["HEALTH"])
	if self._gun:
		self._gun.ammo_count = data["AMMO"]

	update_health_bar()
	update_ammo_counter()


func set_weapon_disabled(val):
	weapon_disabled = val
	if self._gun:
		self._gun.set_disabled(val)


func _remove_weapon(parent: Node2D, weapon: Node2D):
	var visuals = parent.get_child(0)
	parent.remove_child(visuals)
	weapon.get_parent().remove_child(weapon)
	visuals.queue_free()

	var pickup = WorldWeapon.new()
	pickup.set_weapon(weapon)
	pickup.auto_pickup = false
	pickup.global_position = self.global_position * MathUtils.TO_ISO
	Scene.runtime.add_child(pickup)


func _update_weapons_ui():
	var ui = Scene.ui.get_node("HUD")
	var gun = ui.get_node("CurrentGun")
	var melee = ui.get_node("CurrentMelee")
	gun.texture = self._gun.world_sprite if self._gun else null
	melee.texture = self._melee.world_sprite if self._melee else null


func set_gun(gun: PlayerBaseGun):
	if gun == self._gun:
		return

	if self.flash_node.get_parent():
		self.flash_node.get_parent().remove_child(self.flash_node)

	if self._gun:
		_remove_weapon(self.hand, self._gun)

	self._gun = gun.with_parent(self)
	self._gun.set_aim_bone(arms_container)
	self._gun.set_muzzle_flash_sprite(self.flash_node.get_child(0))
	reapply_upgrades()
	self.hand.add_child(self._gun.with_visuals(self._gun.default_visual_scene()))
	self._gun.add_child(self.flash_node)
	update_ammo_counter()
	_update_weapons_ui()


func set_melee(melee: Melee):
	if melee == self._melee:
		return
	if self._melee:
		_remove_weapon(self.melee_hand, self._melee)
		self._melee.detach()

	self._melee = melee.with_parent(self)
	reapply_upgrades()
	self.melee_hand.add_child(self._melee.with_visuals(self._melee.default_visual_scene()))
	self._melee.apply_to_attack(self.melee_hitbox)
	_update_weapons_ui()


func get_melee_attack_speed():
	if self._melee:
		return self._melee.attack_speed
	return 1.0


func has_gun() -> bool:
	return self._gun != null


func has_melee() -> bool:
	return self._melee != null


func get_wanted_direction():
	var dir = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if dir.length() > 1:
		dir = dir.normalized()
	return dir


func get_input_velocity():
	return get_wanted_direction() * getv(LivingEntityVariable.MAX_SPEED)


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


func update_ammo_counter(remove: bool = false):
	var ammo_count = Scene.ui.get_node("HUD/AmmoCount")
	if remove or not self._gun:
		ammo_count.text = String("0")
	else:
		ammo_count.text = (
			String(self._gun.get_ammo_count())
			+ "/"
			+ String(self._gun.get_max_ammo())
		)

	if not self._gun:
		return

	if self._gun.get_ammo_count() == 0:
		ammo_count.modulate = Constants.COLOR.RED
	else:
		ammo_count.modulate = Constants.COLOR.WHITE


func add_ammo(ammo: int) -> int:
	if self._gun:
		var diff = self._gun.add_ammo(ammo)
		update_ammo_counter()
		return diff

	return 0


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


func get_all_upgrade_handlers() -> Array:
	var arr = [self.upgrade_handler, self.melee_hitbox.upgrade_handler]
	if self._gun:
		arr.append(self._gun.upgrade_handler)
	if self._melee:
		arr.append(self._melee.upgrade_handler)
	return arr


func _update_shader():
	var t = self.get_global_transform_with_canvas().origin / get_viewport().get_visible_rect().size
	t.y = 1 - t.y
	Scene.wall_material.set_shader_param("target", t)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	_update_reload_progress()
	_update_shader()
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
			SaveHelper.save()
		if Input.is_action_just_pressed("ui_home"):
			SaveHelper.load_game()
			# var scene = load("res://Scenes/Levels/BossRoom.tscn").instance()
			# TransitionHelper.transition(scene, true, true, 0.01)
		if Input.is_action_just_pressed("ui_page_down"):
			# var scene = load("res://Scenes/Levels/BossRoom.tscn").instance()
			# TransitionHelper.transition(scene, true, true, 0.01)
			for enemy in AI.get_all_enemies():
				enemy.queue_free()
		if Input.is_action_just_pressed("ui_page_up"):
			#apply_upgrades([HomingUpgrade.new()])
			self.kill()


#			var d = DualUpgrade.new()
#			Scene.runtime.add_child(d)
#			d.global_position = self.global_position


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
	bar.value = ((getv(LivingEntityVariable.HEALTH) / getv(LivingEntityVariable.MAX_HEALTH)) * 100)


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
	fx.initialize(direction.angle() + (2 * PI), info.damage)
	self.add_child(fx)
	fx.position = Vector2(5, -45)
	fx.scale = Vector2.ONE / 1.5
	self.status_timers.set_timer(LivingEntityStatus.INVULNERABLE, INVULNERABLE_TIME)
	update_health_bar()
	Scene.ui.get_node("DamageFeedback").add_value(info.damage / 25.0)
	if info.damage <= 15:
		Wwise.post_event_id(AK.EVENTS.SMALL_HURT_PLAYER, self)
	elif info.damage <= 20:
		Wwise.post_event_id(AK.EVENTS.MEDIUM_HURT_PLAYER, self)
	else:
		Wwise.post_event_id(AK.EVENTS.BIG_HIT_PLAYER, self)
	._on_take_damage(info)


func _on_death(info: AttackInfo):
	update_ammo_counter(true)
	self._knockback_velocity = Vector2.ZERO
	self.fsm.set_state(PlayerState.DEAD, true)
	self.fsm.lock()
	if self._gun:
		self._gun.queue_free()
	self._gun = null
	if info and info.damage_source is BaseEnemy:
		StatsTracker.add_death(info.damage_source.get_entity_name())
	else:
		StatsTracker.add_death()
