# Author: Marcus
# Static class

class_name AI extends Node2D


static func get_all_enemies():
	return Scene.get_tree().get_nodes_in_group("Enemy")


static func _propogate_alert(location):
	pass


static func notify_hit(source):
	pass


static func has_LOS(from: Vector2, to: Vector2) -> bool:
	return _can_sound_travel(MathUtils.line_coords_world(from, to), 0)


static func _can_sound_travel(coords: Array, strength: int) -> bool:
	var is_in_wall = 0
	for coord in coords:
		var t = Scene.level[coord.x][coord.y]
		if not is_in_wall and t == Constants.TILE_TYPE.WALL:
			strength -= 1
			is_in_wall = true
			if strength < 0:
				return false
		elif is_in_wall and t != Constants.TILE_TYPE.WALL:
			is_in_wall = false
	return true


static func notify_sound(location: Vector2, max_dist: float = 1024, strength: int = 1) -> void:
	for enemy in get_all_enemies():
		var dist = (location - enemy.global_position).length()
		if dist > max_dist:
			continue
		var line = MathUtils.line_coords(
			MathUtils.to_level_vector(location), MathUtils.to_level_vector(enemy.global_position)
		)
		if _can_sound_travel(line, strength):
			enemy.set_investigate_target(location)
