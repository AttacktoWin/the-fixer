# Author: Marcus

extends Node

const SAVE_LEVEL_ID = "LEVEL_ID"
const SAVE_LEVEL_DATA = "LEVEL_DATA"
const PERMANENT_UPGRADES = "PERMANENT_UPGRADES"
const PATCHES = "PATCHES"
const SAVE_FILE_NAME = "user://game_data.save"

const SAVE_SETTINGS_FILE_NAME = "user://game_settings.save"

const KEYMAP_FILE_NAME = "user://game_keymappings.save"
const MAPPABLE_KEYS = ["pickup_weapon", "weapon_fire_ranged", "weapon_fire_melee", "move_dash"]

# i am too lazy to put this somewhere better.
var keymappings = {}

func _ready():
	for action in MAPPABLE_KEYS:
		var events = InputMap.get_action_list(action)
		if events.size() != 0:
			self.keymappings[action] = events
	load_settings()

func save_keymap():
	var file = File.new()
	file.open(KEYMAP_FILE_NAME, File.WRITE)
	file.store_var(self.keymappings, true)
	file.close()

func save_settings() -> void:
	var data = {}
	data["master_volume"] = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.MASTER, Scene)
	data["music_volume"] = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, Scene)
	data["ui_volume"] = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.UIVOLUME, Scene)
	data["aim_assist"] = AI.aim_assist

	var file = File.new()
	file.open(SAVE_SETTINGS_FILE_NAME, File.WRITE)
	file.store_string(JSON.print(data))
	file.close()

	save_keymap()

func load_keymap():
	var file = File.new()
	if not file.file_exists(KEYMAP_FILE_NAME):
		return
	file.open(KEYMAP_FILE_NAME, File.READ)
	var temp_keymap = file.get_var(true) as Dictionary
	file.close()

	for action in MAPPABLE_KEYS:
		if temp_keymap.has(action):
			self.keymappings[action] = temp_keymap[action]
			# Whilst setting the keymap dictionary, we also set the
			# correct InputMap event
			InputMap.action_erase_events(action)
			var mapping = self.keymappings[action]
			if not mapping is Array:
				mapping = [mapping]
			for event in mapping:
				InputMap.action_add_event(action, event)
	

func load_settings() -> void:
	var data = load_json_file(SAVE_SETTINGS_FILE_NAME, {})
	Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MASTER, data.get("master_volume",100), Scene) 
	Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, data.get("music_volume",100), Scene) 
	Wwise.set_rtpc_id(AK.GAME_PARAMETERS.UIVOLUME, data.get("ui_volume",100), Scene)
	AI.aim_assist = data.get("aim_assist", 0.5)

	load_keymap()

	

func save() -> void:
	DialogueSystem.save()
	var data = {}
	data[SAVE_LEVEL_DATA] = Scene.level_node.save()
	data[SAVE_LEVEL_ID] = Scene.level_node.level_index
	data[PERMANENT_UPGRADES] = StatsSingleton.save()
	_save(data)
	
func _save(data: Dictionary):
	var file = File.new()
	file.open(SAVE_FILE_NAME, File.WRITE)
	file.store_string(JSON.print(data))
	file.close()

func load_game():
	# prevent gun firing
	if not PausingSingleton.is_paused():
		PausingSingleton.pause()
		PausingSingleton.unpause()
	TransitionHelper.transition_fade()
	var data = load_json_file(SAVE_FILE_NAME)
	StatsSingleton.load_data(data[PERMANENT_UPGRADES])
	UpdateSingleton.load_patches(data.get(PATCHES, {}))
	var level_id = data[SAVE_LEVEL_ID]

	var scene: PackedScene = null
	var spawn_player = true

	# special cases...
	if level_id <= 0:
		if level_id == 0:  # hub
			scene = load("res://Scenes/Levels/Hub.tscn")
			spawn_player = false
		if level_id == -1:  # tutorial
			scene = load("res://Scenes/Levels/Tutorial.tscn")
			spawn_player = false
		if level_id == -2:  # boss
			scene = load("res://Scenes/Levels/BossRoom.tscn")
	else:
		scene = load("res://Scenes/Levels/Level" + String(level_id) + ".tscn")

	var instance = scene.instance()
	if spawn_player:
		var player = preload("res://Scenes/Player/Player.tscn").instance()
		player.name = "Player"
		instance.get_node("SortableEntities").add_child(player)

	instance.load_data(data[SAVE_LEVEL_DATA])
	Scene.switch(instance, false)

func run_patch(patch: Runnable) -> bool:
	var save = load_json_file(SAVE_FILE_NAME)
	var patcher = patch.new(save)
	var patched_save = patcher.run(null)
	if (patched_save != false):
		_save(patched_save)
		return true
	return false

func has_save_file() -> bool:
	return File.new().file_exists(SAVE_FILE_NAME)


func load_json_file(file_name: String, _default=null) -> Dictionary:
	var file = File.new()
	if not file.file_exists(file_name) and _default != null:
		return _default
	
	file.open(file_name, File.READ)
	var text = file.get_as_text()
	file.close()

	var json = JSON.parse(text)

	if json.error == OK:
		if typeof(json.result) == TYPE_DICTIONARY:
			return json.result as Dictionary
		else:
			print("Malformed save data.")
	else:
		print("JSON Parse Error: ", json.error, " in ", text, " at line ", json.error_line)

	return {}
