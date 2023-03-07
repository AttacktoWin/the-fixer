# Author: Marcus

extends Node

var _root = null

var camera setget , _get_camera
var runtime setget , _get_runtime
var ui setget , _get_ui
var managers setget , _get_managers

var _camera = null
var _runtime = null
var _ui = null
var _managers = null


func set_root(root: Node2D):
	self._root = root
	self._camera = root.get_node("MainCamera")
	self._runtime = root.get_node("Level/SortableEntities/Runtime")
	self._ui = root.get_node("MainCamera/UI")
	self._managers = root.get_node("Managers")


func _get_camera() -> Node:
	return self._camera


func _get_runtime() -> Node:
	return self._runtime


func _get_ui() -> Node:
	return self._ui


func _get_managers() -> Node:
	return self._managers


func deload():
	if not self._runtime:
		print("No level loaded!")
		return
	var level = self._root.get_node("Level")
	self._root.remove_child(level)
	level.queue_free()
	self._runtime = null


func load(level: Node):
	if self._runtime:
		print("Current level still loaded!")
		return
	self._root.add_child(level)
	self._root.move_child(level, 0)
	self._runtime = self._root.get_node("Level/SortableEntities/Runtime")


func switch(level: Node):
	self.deload()
	self.load(level)


var Demo1 = preload("res://Scenes/Levels/Demo2.tscn")
