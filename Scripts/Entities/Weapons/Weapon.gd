class_name Weapon extends Node2D

var _cooldown_timer = Timer.new()
var _can_fire = true
var _cooldown = 0.5  # seconds
var _parent = null


func _try_fire(direction, target = null):
	if not self._can_fire or not self._check_fire(direction, target):
		return false
	self._can_fire = false
	self._cooldown_timer.wait_time = self._cooldown
	self._cooldown_timer.start()
	_fire(direction, target)
	return true


func _check_fire(_direction, _target):
	return true


func _fire(_direction, _taget = null):
	print("Not implemented!")


func set_parent(parent):
	self._parent = parent


func _cooldown_complete():
	self._can_fire = true


func _init():
	pass


func _ready():
	# self._cooldown_timer.one_shot = true
	self._cooldown_timer.connect("timeout", self, "_cooldown_complete")
	add_child(self._cooldown_timer)


func on_fire_called():
	self._try_fire(CameraSingleton.get_mouse_from_camera_center().angle(), null)


func check_fire_pressed():
	return false


func _process(_delta):
	if self.check_fire_pressed():
		on_fire_called()
