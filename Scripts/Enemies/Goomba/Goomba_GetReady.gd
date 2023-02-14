# Author: Yalmaz
# Description: State used to by goomba when getting into position
extends Base_EnemyState

var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var hop_timer = 0.0


# Description: Handles the hop logic when getting into position
func _getReady(_delta):
	hop_timer += _delta
	state_machine.position = start_pos.linear_interpolate(
		end_pos, hop_timer / state_machine.hop_time
	)


########################################################################
#Overrides
########################################################################
func on_enter() -> void:
	.on_enter()
	hop_timer = 0

	start_pos = self.global_position
	end_pos = (
		(-get_DirectionToPlayer(self) * state_machine.hop_distance)
		+ start_pos
	)


func physics_tick(_delta: float) -> void:
	_getReady(_delta)


########################################################################
#DEBGU CODE
########################################################################
func _draw():
	if is_Active:
		pass
