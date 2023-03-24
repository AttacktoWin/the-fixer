# Author: Marcus

extends Node

var _root = null

var camera setget , _get_camera
var runtime setget , _get_runtime
var ui setget , _get_ui
var managers setget , _get_managers
var level setget , _get_level

var _camera = null
var _runtime = null
var _ui = null
var _managers = null
var _level = null


func _reload_variables():
	self._camera = self._root.get_node("MainCamera")
	self._runtime = self._root.get_node("Level/SortableEntities/Runtime")
	self._ui = self._root.get_node("UILayer/UI")
	self._managers = self._root.get_node("Managers")
	self._level = self._root.get_node("Level/Generator").level
	Pathfinder.update_level(self._level)


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


func get_tree() -> SceneTree:
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
	self.deload()
	self.load(new_level)
