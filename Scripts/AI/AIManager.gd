# Author: Marcus
# Singleton
extends Node2D

signal on_global_aggro_changed

var _has_aggro = false

var aim_assist = 0.5


func _physics_process(_delta):
	if self._has_aggro:
		for enemy in get_all_enemies():
			if enemy.has_target():
				return
		self._has_aggro = false
		emit_signal("on_global_aggro_changed", false)
	else:
		for enemy in get_all_enemies():
			if enemy.has_target():
				self._has_aggro = true
				emit_signal("on_global_aggro_changed", true)
				return


func get_all_enemies():
	return Scene.get_tree().get_nodes_in_group("Enemy")


func has_LOS(from: Vector2, to: Vector2) -> bool:
	return _can_sound_travel(MathUtils.line_coords_world(from, to), 0)


func _can_sound_travel(coords: Array, strength: float, decay: float = 0) -> bool:
	var is_in_wall = 0
	for coord in coords:
		var t = Scene.level[coord.x][coord.y]
		if t != Constants.TILE_TYPE.FLOOR:
			strength -= decay
		if not is_in_wall and t == Constants.TILE_TYPE.WALL:
			strength -= 1
			is_in_wall = true
			if strength < 0:
				return false
		elif is_in_wall and t != Constants.TILE_TYPE.WALL:
			is_in_wall = false
	return strength >= 0


func notify_sound(
	location: Vector2, max_dist: float = 1024, strength: float = 2, decay: float = 0.05
) -> void:
	for enemy in get_all_enemies():
		if enemy.deaf:
			continue
		var dist = (location - enemy.global_position).length()
		if dist > max_dist:
			continue
		var line = MathUtils.line_coords(
			MathUtils.to_level_vector(location), MathUtils.to_level_vector(enemy.global_position)
		)
		if _can_sound_travel(line, strength, decay):
			enemy.set_investigate_target(location)
