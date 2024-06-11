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
var wall_material setget , _get_wall_material

var _camera = null
var _runtime = null
var _ui = null
var _ui_layer = null
var _managers = null
var _level = null
var _level_node = null
var _player = null
var _exit = null
var _wall_material = null

var _current_music = null
var _current_music_id = null

var _marked_inputs = {}
var _primary_control = 0

signal transition_start
signal transition_complete
signal world_updated


func _ready():
	randomize()
	Wwise.register_listener(self)
	Wwise.register_game_obj(self, self.name)
	self.process_priority = 1


func _physics_process(_delta):
	self._marked_inputs = {}


func _update_pathfinder():
	if self._level != null:
		self._level = self._level.level
		Pathfinder.update_level(self._level)


func _reload_variables(new_level: Level):
	self._camera = self._root.get_node("MainCamera")
	self._ui = self._root.get_node("UILayer/UI")
	self._ui_layer = self._root.get_node("UILayer")
	self._managers = self._root.get_node("Managers")
	self._level_node = self._root.get_node_or_null("Level")  # edge case for start level
	if new_level != null:
		Pathfinder.update_level([[]])
		self._runtime = new_level.get_node_or_null("SortableEntities/Runtime")
		self._level = new_level.get_node_or_null("Generator")
		self._level_node = new_level
		self._exit = new_level.get_node_or_null("Transition/Hitbox")
		self._wall_material = new_level.get_node_or_null("%Walls")
		if self._wall_material:
			self._wall_material = self._wall_material.material
		if self._player == null:
			self._player = new_level.get_node_or_null("SortableEntities/Player")


func _process(_delta):
	var v = Vector2(
		(
			Input.get_action_strength("weapon_aim_right")
			- Input.get_action_strength("weapon_aim_left")
		),
		Input.get_action_strength("weapon_aim_down") - Input.get_action_strength("weapon_aim_up")
	)
	if v.length() > 0.25:
		self._primary_control = 1
	var inputs = [
		Input.get_action_strength("move_right"),
		Input.get_action_strength("move_up"),
		Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down")
	]
	for input in inputs:
		if input > 0.1 and input != 1:
			self._primary_control = 1


func _input(event):
	if event is InputEventKey or event is InputEventMouse:
		self._primary_control = 0
	if event is InputEventJoypadButton:
		self._primary_control = 1


func is_controller():
	return self._primary_control == 1


func set_root(root: Node2D):
	self._root = root
	_reload_variables(null)


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


func _get_player():
	return self._player


func _get_exit():
	return self._exit


func _get_wall_material():
	return self._wall_material


func mark_input(ev_name):
	self._marked_inputs[ev_name] = true


func is_input_marked(ev_name):
	return ev_name in self._marked_inputs


func get_tree() -> SceneTree:
	if !is_instance_valid(self._root):
		# Running some sort of test
		self._root = Node2D.new()
		add_child(self._root)
	return self._root.get_tree()


func deload():
	if not self._level_node:
		print("No level loaded!")
		return
	self._level_node.get_parent().remove_child(self._level_node)
	self._level_node.queue_free()
	self._level_node = null
	self._player = null


func load(new_level: Level):
	if self._level_node:
		print("Current level still loaded!")
		return
	_reload_variables(new_level)
	if new_level.is_ui:
		self._root.get_node("UILayer").add_child(new_level)
		#self._root.get_node("UILayer").move_child(new_level, 0)
	else:
		self._root.add_child(new_level)
		self._root.move_child(new_level, 0)
	_update_pathfinder()
	# ORDER MATTERS FOR SAVE!!!
	emit_signal("transition_complete")
	emit_signal("world_updated")
	play_level_music()
	set_contrast_mode()

func set_contrast_mode():
	var status = SaveHelper.contrast_mode
	
	for enemy in AI.get_all_enemies():
		if status:
			_player.visual.get_node("PlayerSprite").material.set_shader_param("c_strength",1)
			_player.arms_container.get_node("Arm").material.set_shader_param("c_strength",1)
			_player.visual.get_node("Arm2").material.set_shader_param("c_strength",1)
			enemy.sprite_material.set_shader_param("c_strength",1)
		else:
			_player.visual.get_node("PlayerSprite").material.set_shader_param("c_strength",0)
			_player.arms_container.get_node("Arm").material.set_shader_param("c_strength",0)
			_player.visual.get_node("Arm2").material.set_shader_param("c_strength",0)
			enemy.sprite_material.set_shader_param("c_strength",0)

func play_level_music():
	if not self._level_node:
		clear_music()
		return
	play_music(self._level_node.level_music)


func clear_music():
	play_music(0)


func play_music(id_to_play: int):
	var old_id = self._current_music_id
	self._current_music_id = id_to_play

	if not id_to_play:
		if self._current_music:
			Wwise.stop_event(self._current_music, 500, AkUtils.AkCurveInterpolation.EXP3)
		self._current_music = null
		return

	if id_to_play != old_id:
		if self._current_music:
			Wwise.stop_event(self._current_music, 500, AkUtils.AkCurveInterpolation.EXP3)
		self._current_music = Wwise.post_event_id(id_to_play, self)


func switch(new_level: Level, transfer_player: bool = false):
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


