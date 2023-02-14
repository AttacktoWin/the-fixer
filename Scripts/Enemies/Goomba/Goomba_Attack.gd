# Author: Yalmaz
# Description: State used to handle goomba's lunge attack
extends Base_EnemyState

var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var lunge_timer = 0.0


# Description: Used to switch the hurtbox on and off
func hurtBoxSwitch():
	print("test")


# Description: Handles the lunge logic
func _attack(_delta):
	if animator.get_current_node() == "ATTACK":
		lunge_timer += _delta
		state_machine.position = start_pos.linear_interpolate(
			end_pos, lunge_timer / state_machine.lunge_time
		)


########################################################################
#Overrides
########################################################################
func on_enter(_msg: Dictionary = {}) -> void:
	.on_enter(_msg)
	lunge_timer = 0

	start_pos = state_machine.global_position
	end_pos = (
		(get_DirectionToPlayer(self) * state_machine.lunge_distance)
		+ start_pos
	)
	print(end_pos)


func physics_tick(_delta: float) -> void:
	_attack(_delta)
