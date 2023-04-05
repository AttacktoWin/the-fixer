# Author: Marcus

extends Node

var _root = null

var camera setget , _get_camera
var runtime setget , _get_runtime
var ui setget , _get_ui
var ui_layer setget , _get_ui_layer
var managers setget , _get_managers
var level setget , _get_level
var level_node setget , _get_level_node
var player setget , _get_player
var exit setget , _get_exit

var _camera = null
var _runtime = null
var _ui = null
var _ui_layer = null
var _managers = null
var _level = null
var _level_node = null
var _player = null
var _exit = null

signal transition_start
signal transition_complete
signal world_updated


func _reload_variables():
	self._camera = self._root.get_node("MainCamera")
	self._runtime = self._root.get_node("Level/SortableEntities/Runtime")
	self._ui = self._root.get_node("UILayer/UI")
	self._ui_layer = self._root.get_node("UILayer")
	self._managers = self._root.get_node("Managers")
	self._level = self._root.get_node("Level/Generator").level
	self._level_node = self._root.get_node("Level")
	self._exit = self._root.get_node("Level/Transition/Hitbox")
	if self._player == null:
		self._player = self._root.get_node("Level/SortableEntities/Player")
	
	Pathfinder.update_level(self._level)
	emit_signal("world_updated")
	emit_signal("transition_complete")


func set_root(root: Node2D):
	self._root = root
	_reload_variables()


func _get_camera() -> Node:
	return self._camera


func _get_runtime() -> Node:
	return self._runtime


func _get_ui() -> Node:
	return self._ui


func _get_ui_layer() -> Node:
	return self._ui_layer


func _get_managers() -> Node:
	return self._managers


func _get_level() -> Array:
	return self._level


func _get_level_node() -> Node2D:
	return self._level_node


func _get_player() -> Player:
	return self._player

func _get_exit():
	return self._exit


func get_tree() -> SceneTree:
	if !is_instance_valid(self._root):
		# Running some sort of test
		self._root = Node2D.new()
		add_child(self._root)
	return self._root.get_tree()


func deload():
	if not self._runtime:
		print("No level loaded!")
		return
	var current_level = self._root.get_node("Level")
	self._root.remove_child(current_level)
	current_level.queue_free()
	self._runtime = null
	self._player = null


func load(new_level: Node):
	if self._runtime:
		print("Current level still loaded!")
		return
	self._root.add_child(new_level)
	self._root.move_child(new_level, 0)
	_reload_variables()


func switch(new_level: Node, transfer_player: bool = false):
	emit_signal("transition_start")
	if transfer_player:
		var player_inst = self._player
		player_inst.get_parent().remove_child(player_inst)
		assert(
			new_level.get_node_or_null("SortableEntities/Player") == null,
			"Cannot transfer player to scene with existing player!"
		)
		new_level.get_node("SortableEntities").add_child(player_inst)
		self.deload()
		self._player = player_inst
		self.load(new_level)
	else:
		self.deload()
		self.load(new_level)
