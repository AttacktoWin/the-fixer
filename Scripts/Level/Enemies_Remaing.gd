extends Node

var indicator_scene = preload("res://Scenes/Interface/EnemyIndicator.tscn")
var indicators = []

const MAX_DIST = 450

func _ready():
	Scene.connect("world_updated", self, "_reload")  # warning-ignore:return_value_discarded


func _reload():
	if Scene.exit:
		Scene.exit.connect("on_displayed", self, "_show")
		Scene.exit.connect("on_clear_display", self, "_clear")

func _input(_event):
	if Input.is_action_just_pressed("show_enemies") and Scene.exit:
		_show()
	if Input.is_action_just_released("show_enemies") and Scene.exit:
		_clear()

func _get_target_instances():
	var enemies = AI.get_all_enemies()
	if(enemies.size() == 0):
		enemies = [Scene.exit]
	return enemies

func _process(_delta):
	if not Scene.player:
		return
	if Scene.exit and AI.get_all_enemies().size() == 0:
		if Scene.exit.should_search_exit():
			_show()
		else:
			_clear()
			return
	#Update the position of indicators
	var player_node = Scene.player
	var player_pos = player_node.get_global_transform_with_canvas().origin
	var enemies = _get_target_instances()
	var index = 0

	for indicator in indicators:
		if index >= enemies.size():
			break
		var enemy_pos = enemies[index].get_global_transform_with_canvas().origin
		var dir: Vector2 = enemy_pos - player_pos
		var dist = dir.limit_length(MAX_DIST)
		indicator.global_position = player_pos + dist
		index += 1

	#turn off any indicators for enemies that die. theyll get cleaned later
	for i in range(index, indicators.size()):
		indicators[i].visible = false


func _show():
	#spawn indicators and direct them towards enemies
	var player_node = Scene.player
	var player_pos = player_node.get_global_transform_with_canvas().origin

	for enemy in _get_target_instances():
		#spawn
		var indicator = indicator_scene.instance()
		add_child(indicator)
		indicators.append(indicator)
		#position
		var enemy_pos = enemy.get_global_transform_with_canvas().origin
		var dir: Vector2 = (enemy_pos - Vector2(0, 30)) - player_pos
		var dist = dir.limit_length(MAX_DIST)
		indicator.global_position = player_pos + dist


func _clear():
	#clean up
	for indicator in indicators:
		indicator.queue_free()
	indicators = []
