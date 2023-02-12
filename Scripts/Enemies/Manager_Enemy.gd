extends Node2D

var enemies = []
onready var _player = get_node("%Player")


func get_DistanceToPlayer(enemy_position) -> float:
	return enemy_position.distance_to(_player.global_position)


func get_DirectionToPlayer(enemy_position) -> Vector2:
	return (_player.global_position - enemy_position).normalized()


func is_PlayerInRange(enemy_position, detection_range) -> bool:
	return get_DistanceToPlayer(enemy_position) <= detection_range


func get_AngleToPlayer(enemy_node) -> float:
	return rad2deg(enemy_node.get_angle_to(_player.global_position))


func get_PlayerInLocal(enemy_node) -> Vector2:
	return enemy_node.to_local(_player.global_position)


########################################################################
#Life Cycle Functions
########################################################################
func _ready():
	get_tree().call_group("Enemy", "set_manager", self)
# func _process(_delta):
# 	for enemy in enemies:
# 		enemy.current_state.update()
