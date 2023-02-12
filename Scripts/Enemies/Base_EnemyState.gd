# Author: Yalmaz
# Description: Interface to be implemented when making a node
class_name Base_EnemyState
extends Base_State

var sprite: Sprite = null
var parent: Node2D = null
var animator = null
var player: Node2D = null
var previous_state = "Root"


# Description: temporary method for testing hit animation
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("ui_right"):
		state_machine.transition_to("STAGGER")


# Description: used to flip sprite based on player position relative to self
func flipSprite():
	var angle = get_AngleToPlayer(self)
	if angle < 90 and angle > -90:
		sprite.flip_h = true
	else:
		sprite.flip_h = false


# Description: Get distance to player
func get_DistanceToPlayer(enemy_node: Node2D) -> float:
	return enemy_node.global_position.distance_to(player.global_position)


# Description: Get direction to player
func get_DirectionToPlayer(enemy_node: Node2D) -> Vector2:
	return (player.global_position - enemy_node.global_position).normalized()


# Description: Check if player is within set range
func is_PlayerInRange(enemy_node: Node2D, detection_range) -> bool:
	return get_DistanceToPlayer(enemy_node) <= detection_range


# Description: Check angle to player
func get_AngleToPlayer(enemy_node: Node2D) -> float:
	return rad2deg(enemy_node.get_angle_to(player.global_position))


# Description: Get player position relative to player
func get_PlayerInLocal(enemy_node: Node2D) -> Vector2:
	return enemy_node.to_local(player.global_position)


########################################################################
#Overrides
########################################################################
func exit():
	.exit()
	update()
