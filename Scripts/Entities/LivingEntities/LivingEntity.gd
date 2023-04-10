# Author: Marcus

class_name LivingEntity extends Entity

export var base_speed: float = 340
export var base_health: float = 100
export var base_accel: float = 80
export var base_drag: float = 1.025
export var base_weight: float = 1
onready var variables = VariableList.new(
	self,
	LivingEntityVariable.get_script_constant_map(),
	{
		LivingEntityVariable.MAX_SPEED: base_speed,
		LivingEntityVariable.HEALTH: base_health,
		LivingEntityVariable.MAX_HEALTH: base_health,
		LivingEntityVariable.ACCEL: base_accel,
		LivingEntityVariable.VELOCITY: Vector2(),
		LivingEntityVariable.DRAG: base_drag,
		LivingEntityVariable.KNOCKBACK_FACTOR: 1,
		LivingEntityVariable.WEIGHT: base_weight
	}
)

var healing_multiplier = 1.0

onready var status_timers = TimerList.new(self, LivingEntityStatus.get_script_constant_map(), {})

export var push_amount: float = 256
export(NodePath) var entity_collider_path = NodePath("EntityCollider")

var upgrade_handler = UpgradeHandler.new(self, UpgradeType.ENTITY, true)

var disable_pushing: int = 0

var _entity_collider = null

var _is_dead = false

const INVULNERABLE_FLASH_RATE = 0.1

signal on_death


func _get_node_or_err(test_path, default_path):
	var node = null
	if test_path:
		node = get_node_or_null(test_path)
	if not node and default_path:
		node = get_node_or_null(default_path)

	if not node:
		print("WARN: required node for '", default_path, "' not found in entity '", self.name, "'!")
	return node


func _on_pause_change(should_pause, ignore_entity):
	if ignore_entity == self:
		return
	set_process(not should_pause)
	set_physics_process(not should_pause)


func _ready():
	self._entity_collider = self._get_node_or_err(entity_collider_path, "EntityCollider")
	# linter is mad at me
	var _error = null
	_error = PausingSingleton.connect("pause_changed", self, "_on_pause_change")
	if _error:
		print("Error connecting to pause: ", _error)

	add_child(variables)
	add_child(status_timers)

	_add_default_runnables()


func _add_default_runnables():
	self.variables.add_runnable(LivingEntityVariable.MAX_SPEED, BaseSlowHandler.new())


func get_entity_name():
	print("WARN: display name not set for ", name, "!")
	return ""


func getv(variable):
	return self.variables.get_variable(variable)


func setv(variable, v):
	return self.variables.set_variable(variable, v)


func changev(variable: int, off):
	return setv(variable, getv(variable) + off)


func get_wanted_velocity(dir_vector: Vector2) -> Vector2:
	return dir_vector * getv(LivingEntityVariable.MAX_SPEED)


func update_health_bar():
	pass


func reapply_upgrades():
	apply_upgrades(self.upgrade_handler.get_all_known_upgrades())


func get_all_upgrade_handlers():
	return [self.upgrade_handler]


func apply_upgrades(upgrades: Array):
	for handler in get_all_upgrade_handlers():
		handler.add_upgrades(upgrades)


func add_health(value: int):
	var health = getv(LivingEntityVariable.HEALTH)
	health = health + round(value * self.healing_multiplier)
	var m = getv(LivingEntityVariable.MAX_HEALTH)
	if health > m:
		health = m
	setv(LivingEntityVariable.HEALTH, health)
	update_health_bar()


func _try_move():
	# warning-ignore:return_value_discarded
	var v = getv(LivingEntityVariable.VELOCITY)
	if is_nan(v.x) or is_nan(v.y):
		setv(LivingEntityVariable.VELOCITY, Vector2())
		return
	move_and_slide(v)


func _get_base_alpha() -> float:
	return 1.0


func _handle_alpha():
	var t = self.status_timers.get_timer(LivingEntityStatus.INVULNERABLE)
	if t == 0 or self._is_dead:
		self.modulate.a = 1 * self._get_base_alpha()
	else:
		var frac = fmod(t, INVULNERABLE_FLASH_RATE)
		if frac < INVULNERABLE_FLASH_RATE / 2:
			self.modulate.a = 0.25 * self._get_base_alpha()
		else:
			self.modulate.a = 1 * self._get_base_alpha()


func _process(_delta):
	_handle_alpha()


func _physics_process(delta):
	var push_dir = Vector2()
	if not self.disable_pushing:
		var colliding = CollisionUtils.get_overlapping_bodies_filtered(
			self._entity_collider, self, KinematicBody2D
		)
		for other in colliding:
			var v = self.global_position - other.global_position
			var dist = v.length()
			var max_dist = self.entity_radius + other.entity_radius
			if dist > max_dist:
				dist = max_dist

			var interp = MathUtils.interpolate(
				dist / max_dist, other.push_amount, 0, MathUtils.INTERPOLATE_OUT
			)

			push_dir += v.normalized() * interp
	# warning-ignore:return_value_discarded
	self.move_and_slide(push_dir * MathUtils.delta_frames(delta))


func is_dead():
	return self._is_dead


func _on_death(_info: AttackInfo):
	print("Rip")


func _check_death(info: AttackInfo = null) -> bool:
	if self.getv(LivingEntityVariable.HEALTH) <= 0 and not self._is_dead:
		self._is_dead = true
		# queue_free()
		self._on_death(info)
		emit_signal("on_death", self)
		return true
	return false


func kill():
	if self._is_dead:
		return
	setv(LivingEntityVariable.HEALTH, 0)
	update_health_bar()
	self._is_dead = true
	self._on_death(null)
	emit_signal("on_death", self)


func can_attack_hit(_info: AttackInfo) -> bool:
	return true


func can_be_hit():
	return self.status_timers.get_timer(LivingEntityStatus.INVULNERABLE) <= 0 and not self._is_dead


func knockback(_vel: Vector2):
	pass


func on_hit(info: AttackInfo):
	_take_damage(info.damage, info)
	_on_take_damage(info)


func _on_take_damage(_info: AttackInfo):
	pass


func _take_damage(amount: float, info: AttackInfo = null):
	changev(LivingEntityVariable.HEALTH, -amount)
	update_health_bar()
	_check_death(info)  # warning-ignore:return_value_discarded
