# Author: Marcus

extends Node

var _root = null

var camera setget , _get_camera
var runtime setget , _get_runtime
var ui setget , _get_ui
var managers setget , _get_managers
var level setget , _get_level
var player setget , _get_player

var _camera = null
var _runtime = null
var _ui = null
var _managers = null
var _level = null
var _player = null

signal transition_start
signal transition_complete
signal world_updated

func _reload_variables():
	self._camera = self._root.get_node("MainCamera")
	self._runtime = self._root.get_node("Level/SortableEntities/Runtime")
	self._ui = self._root.get_node("UILayer/UI")
	self._managers = self._root.get_node("Managers")
	self._level = self._root.get_node("Level/Generator").level
	self._player = self._root.get_node("Level/Generator").get_node("%Player")
	Pathfinder.update_level(self._level)
	emit_signal("world_updated")
	if (
		self._root.get_node("Level/Generator").get("level_name")
		and self._root.get_node("Level/Generator").level_name == "hub"
	):
		self.emit_signal("transition_complete", true)
	else:
		self.emit_signal("transition_complete", false)


func set_root(root: Node2D):
	self._root = root
	_reload_variables()


func _get_camera() -> Node:
	return self._camera


func _get_runtime() -> Node:
	return self._runtime


func _get_ui() -> Node:
	return self._ui


func _get_managers() -> Node:
	return self._managers


func _get_level() -> Array:
	return self._level


func _get_player() -> KinematicBody2D:
	return self._player


func get_tree() -> SceneTree:
	if (!is_instance_valid(self._root)):
		# Running some sort of test
		self._root = Node2D.new()
		add_child(self._root)
	return self._root.get_tree()


func deload():
	if not self._runtime:
		print("No level loaded!")
		return
	var new_level = self._root.get_node("Level")
	self._root.remove_child(new_level)
	new_level.queue_free()
	self._runtime = null


func load(new_level: Node):
	if self._runtime:
		print("Current level still loaded!")
		return
	self._root.add_child(new_level)
	self._root.move_child(new_level, 0)
	_reload_variables()


func switch(new_level: Node):
	self.emit_signal("transition_start")
	self.deload()
	self.load(new_level)
