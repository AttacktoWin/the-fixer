# Author: Marcus

extends Node

const SAVE_LEVEL_ID = "LEVEL_ID"
const SAVE_LEVEL_DATA = "LEVEL_DATA"
const PERMANENT_UPGRADES = "PERMANENT_UPGRADES"
const SAVE_FILE_NAME = "user://game_data.save"


func save() -> void:
	DialogueSystem.save()
	var data = {}
	data[SAVE_LEVEL_DATA] = Scene.level_node.save()
	data[SAVE_LEVEL_ID] = Scene.level_node.level_index
	data[PERMANENT_UPGRADES] = StatsSingleton.save()
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


func has_save_file() -> bool:
	return File.new().file_exists(SAVE_FILE_NAME)


func load_json_file(file_name: String) -> Dictionary:
	var file = File.new()
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
