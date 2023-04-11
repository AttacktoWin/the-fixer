# Author: Marcus

extends Node

signal pause_changed(pause, _entity)

var _paused_entity = null
var _paused = false
var _unpaused_frames = 0


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
	self._unpaused_frames = -1
	emit_signal("pause_changed", false, _entity)


func _physics_process(_delta):
	self._unpaused_frames += 1


func is_paused():
	return self._paused


func is_paused_recently(frames: int = 30):
	return self._paused or self._unpaused_frames <= frames
