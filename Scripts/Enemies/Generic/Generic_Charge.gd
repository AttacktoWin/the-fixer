# Author: Yalmaz
# Description: Generic state that handles charging up of attack
class_name Generic_CHARGE extends Base_EnemyState

# next animator fsm node to travel to
export(String) var next_node = "ATTACK"


########################################################################
#Overrides
########################################################################
func on_enter() -> void:
	.on_enter()
	yield(get_tree().create_timer(state_machine.charge_time), "timeout")
	animator.travel(next_node)
