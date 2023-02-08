extends Node

signal pause_changed(pause, _entity)

var _paused_entity = null
var _paused = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# entity is an optional entity to pass as an argument to ignore
func pause(_entity = null):
	assert(not self._paused)
	self._paused_entity = _entity
	self._paused = true
	emit_signal("pause_changed", true, _entity)


func unpause(_entity = null):
	assert(self._paused)
	assert(self._paused_entity == _entity)
	self._paused = false
	emit_signal("pause_changed", false, _entity)

func is_paused():
	return self._paused

