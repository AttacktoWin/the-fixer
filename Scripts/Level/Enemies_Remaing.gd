extends Node

var indicator_scene = preload("res://Scenes/Interface/EnemyIndicator.tscn")
var indicators = []


func _ready():
	Scene.connect("world_updated", self, "_reload")  # warning-ignore:return_value_discarded


func _reload():
	if Scene.exit:
		Scene.exit.connect("on_displayed", self, "_show")
		Scene.exit.connect("on_clear_display", self, "_clear")


func _process(_delta):
	if not Scene.player:
		return
	#Update the position of indicators
	var player_node = Scene.player
	var player_pos = player_node.get_global_transform_with_canvas().origin
	var enemies = AI.get_all_enemies()
	var index = 0

	for indicator in indicators:
		if index >= enemies.size():
			break
		var enemy_pos = enemies[index].get_global_transform_with_canvas().origin
		var dir: Vector2 = enemy_pos - player_pos
		var dist = dir.clamped(600)
		indicator.global_position = player_pos + dist
		index += 1

	#turn off any indicators for enemies that die. theyll get cleaned later
	for i in range(index, indicators.size()):
		indicators[i].visible = false


func _show():
	#spawn indicators and direct them towards enemies
	var player_node = Scene.player
	var player_pos = player_node.get_global_transform_with_canvas().origin

	for enemy in AI.get_all_enemies():
		#spawn
		var indicator = indicator_scene.instance()
		add_child(indicator)
		indicators.append(indicator)
		#position
		var enemy_pos = enemy.get_global_transform_with_canvas().origin
		var dir: Vector2 = (enemy_pos - Vector2(0, 30)) - player_pos
		var dist = dir.clamped(396)
		indicator.global_position = player_pos + dist


func _clear():
	#clean up
	for indicator in indicators:
		indicator.queue_free()
	indicators = []
