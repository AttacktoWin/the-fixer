class_name Weapon extends Node2D

var _cooldown_timer = Timer.new()
var _can_fire = true
var _cooldown = 0.5  # seconds
var _aim_bone = null
var _ammo_count = INF
var _max_ammo = INF

var entity = null

signal on_fire
signal on_fire_empty


func _init(parent_entity):
	self.entity = parent_entity


func _ready():
	# self._cooldown_timer.one_shot = true
	self._cooldown_timer.connect("timeout", self, "_cooldown_complete")
	add_child(self._cooldown_timer)


func _try_fire(direction: float, target: Node2D = null) -> bool:
	if not self._can_fire or not self._check_fire(direction, target):
		return false

	self._can_fire = false
	self._cooldown_timer.wait_time = self._cooldown
	self._cooldown_timer.start()

	# fire sound
	if self._ammo_count <= 0:
		emit_signal("on_fire_empty")
		self._notify_fire(false)
		return false
	self._ammo_count -= 1
	_fire(direction, target)
	self._notify_fire(true)
	emit_signal("on_fire")
	return true

func _notify_fire(has_ammo: bool):
	pass


func _check_fire(_direction: float, _target: Node2D) -> bool:
	return true


func _fire(_direction: float, _taget: Node2D = null):
	print("Not implemented!")


func set_aim_bone(bone: Node2D) -> void:
	self._aim_bone = bone


func get_ammo_count() -> int:
	return self._ammo_count


func set_ammo_count(ammo: int):
	self._ammo_count = ammo


func add_ammo(ammo: int):
	if (self._ammo_count == self._max_ammo):
		return
	self._ammo_count += ammo
	
func get_max_ammo() -> int:
	return self._max_ammo
	
func set_max_ammo(ammo: int):
	self._max_ammo = ammo


func _get_aim_position() -> Vector2:
	if self._aim_bone:
		return self._aim_bone.global_position
	return self.global_position


func _cooldown_complete():
	self._can_fire = true


func can_fire() -> bool:
	return self._can_fire and self._ammo_count > 0


func get_angle() -> float:
	return 0.0


func _on_fire_called() -> void:
	# warning-ignore:return_value_discarded
	self._try_fire(self.get_angle(), null)


func _check_fire_pressed() -> bool:
	return false


func _physics_process(_delta):
	if self._check_fire_pressed():
		self._on_fire_called()
