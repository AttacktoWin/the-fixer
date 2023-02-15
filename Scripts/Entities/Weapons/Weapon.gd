class_name Weapon extends Node2D

var _cooldown_timer = Timer.new()
var _can_fire = true
var _cooldown = 0.5  # seconds
var _parent = null
var _aim_bone = null


func _try_fire(direction: float, target: Node2D = null) -> bool:
	if not self._can_fire or not self._check_fire(direction, target):
		return false
	self._can_fire = false
	self._cooldown_timer.wait_time = self._cooldown
	self._cooldown_timer.start()
	_fire(direction, target)
	return true


func _check_fire(_direction: float, _target: Node2D) -> bool:
	return true


func _fire(_direction: float, _taget: Node2D = null):
	print("Not implemented!")


func set_parent(parent: Node2D) -> void:
	self._parent = parent


func set_aim_bone(bone: Node2D) -> void:
	self._aim_bone = bone


func _get_aim_position() -> Vector2:
	if self._aim_bone:
		return self._aim_bone.global_position
	return self.global_position


func _cooldown_complete():
	self._can_fire = true


func _init():
	pass


func _ready():
	# self._cooldown_timer.one_shot = true
	self._cooldown_timer.connect("timeout", self, "_cooldown_complete")
	add_child(self._cooldown_timer)


func can_fire() -> bool:
	return self._can_fire


func get_angle() -> float:
	return 0.0


func _on_fire_called() -> void:
	# warning-ignore:return_value_discarded
	self._try_fire(self.get_angle(), null)


func _check_fire_pressed() -> bool:
	return false


func _process(_delta):
	if self._check_fire_pressed():
		self._on_fire_called()
