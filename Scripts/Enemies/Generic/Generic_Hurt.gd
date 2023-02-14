# Author: Yalmaz
# Description: Generic hurt state. Used to handle getting hit by the enemy. Its the only state that can override fsm control of the animator
class_name Generic_HURT
extends Base_EnemyState

# Hit stun parameters
var stun_duration: float = 0.5
var status: String = ""

# Knock back parameters
var knockback_dir: Vector2 = Vector2.RIGHT
var knockback_dist: float = 20
var knockback_time: float = 0.5
var knockback_timer: float = 0
var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO


########################################################################
#Overrides
########################################################################
func on_enter() -> void:
	knockback_timer = 0
	animator.travel("HURT")
	start_pos = state_machine.global_position
	end_pos = ((knockback_dir * knockback_dist) + start_pos)


func physics_tick(_delta: float) -> void:
	if knockback_timer >= knockback_time:
		animator.travel("CHASE")
		state_machine.transition_to("CHASE")
	knockback_timer += _delta
	state_machine.position = start_pos.linear_interpolate(
		end_pos, knockback_timer / knockback_time
	)
	print(state_machine.position)
