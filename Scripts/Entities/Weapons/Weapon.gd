class_name Weapon extends Node2D

var _cooldown_timer = 0
var _aim_bone = null

export var cooldown: float = 0.5
export var ammo_count: int = 2
export(PackedScene) var ammo_scene = null
export var infinite_ammo: bool = false

var entity = null

signal on_fire
signal on_fire_empty


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

	# fire sound
	if self.ammo_count <= 0 and not self.infinite_ammo:
		emit_signal("on_fire_empty")
		self._notify_fire(false)
		return false

	self.ammo_count -= 1 if not self.infinite_ammo else 0

	_fire(direction, target)
	self._notify_fire(true)
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


func add_ammo(ammo: int):
	self.ammo_count += ammo


func _get_aim_position() -> Vector2:
	if self._aim_bone:
		return self._aim_bone.global_position
	return self.global_position


func can_fire() -> bool:
	return self._cooldown_timer <= 0 and (self.infinite_ammo or self.ammo_count > 0)


func get_angle() -> float:
	return 0.0


func _on_fire_called() -> void:
	# warning-ignore:return_value_discarded
	self._try_fire(self.get_angle(), null)


func _check_fire_pressed() -> bool:
	return false


func _cooldown_timer_tick(delta):
	self._cooldown_timer -= delta


func _physics_process(delta):
	self._cooldown_timer_tick(delta)
	if self._check_fire_pressed():
		self._on_fire_called()
