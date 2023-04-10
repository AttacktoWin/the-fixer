class_name Weapon extends Node2D

var _cooldown_timer = 0
var _aim_bone = null

var _disabled = false

export var cooldown: float = 0.5
export var ammo_count: int = 2
export var max_ammo: int = 10
export(PackedScene) var ammo_scene = null
export(PackedScene) var visual_scene = null
export var infinite_ammo: bool = false
export(Texture) var world_sprite = null

var damage_multiplier = 1.0
var knockback_multiplier = 1.0
var size_multiplier = 1.0

var pierce_chance = 0.0
var refund_chance = 0.0
var multishot_chance = 0.0

var is_spectral = false
var is_homing = false

var upgrade_handler = UpgradeHandler.new(self, UpgradeType.WEAPON)

var entity = null

signal on_fire
signal on_fire_empty
signal on_refund


func _init(_parent_entity: LivingEntity = null):
	self.entity = _parent_entity


func with_parent(parent_entity: LivingEntity):
	self.entity = parent_entity
	return self


func _ready():
	if not self.ammo_scene:
		print("ERR: ammo scene not present!")


func _try_fire(direction: float, target: Node2D = null) -> bool:
	if not self.can_fire() or not self._check_fire(direction, target):
		return false

	self._cooldown_timer = self.cooldown

	self.ammo_count -= 1 if not self.infinite_ammo else 0
	if randf() < self.refund_chance:
		self.ammo_count += 1
		emit_signal("on_refund")

	_fire(direction, target)
	_notify_fire(true)
	emit_signal("on_fire")
	return true


func _notify_fire(_has_ammo: bool):
	pass


func _check_fire(_direction: float, _target: Node2D) -> bool:
	return true


func _fire(_direction: float, _taget: Node2D = null):
	print("Not implemented!")


func set_aim_bone(bone: Node2D) -> void:
	self._aim_bone = bone


func get_ammo_count() -> int:
	return self.ammo_count


func set_ammo_count(ammo: int):
	self.ammo_count = ammo


func add_ammo(ammo: int) -> int:
	var old_count = self.ammo_count
	self.ammo_count += ammo
	if self.ammo_count > self.max_ammo:
		self.ammo_count = self.max_ammo
	return self.ammo_count - old_count


func get_max_ammo() -> int:
	return self.max_ammo

func calc_multishot() -> float:
	var shots = 1
	var t = self.multishot_chance
	while t > 0:
		if randf() < t:
			shots +=1
		t-=1

	return shots

func _get_aim_position() -> Vector2:
	if self._aim_bone:
		return self._aim_bone.global_position
	return self.global_position


func set_disabled(val: bool) -> void:
	self._disabled = not val


func can_fire() -> bool:
	return (
		self._cooldown_timer <= 0
		and (self.infinite_ammo or self.ammo_count > 0)
		and not self._disabled
	)


func get_cooldown_percent():
	return 1 - clamp(self._cooldown_timer / self.cooldown, 0, 1)


func get_angle() -> float:
	return 0.0


func _on_fire_called() -> void:
	# warning-ignore:return_value_discarded
	self._try_fire(self.get_angle(), null)


func _check_fire_just_pressed() -> bool:
	return false


func _check_fire_pressed() -> bool:
	return false


func _cooldown_timer_tick(delta):
	self._cooldown_timer -= delta


func with_visuals(visuals: Node2D):
	if visuals != null:
		if visuals.get_node_or_null("SocketMuzzle"):
			visuals.get_node_or_null("SocketMuzzle").add_child(self)
		else:
			visuals.add_child(self)
		return visuals
	return self


func default_visual_scene():
	if self.visual_scene:
		return self.visual_scene.instance()
	return null


func _physics_process(delta):
	self._cooldown_timer_tick(delta)
	if self._check_fire_pressed():
		self._on_fire_called()
	if (
		not self._disabled
		and self._cooldown_timer < 0
		and self.ammo_count <= 0
		and self._check_fire_just_pressed()
	):
		emit_signal("on_fire_empty")
		self._notify_fire(false)
