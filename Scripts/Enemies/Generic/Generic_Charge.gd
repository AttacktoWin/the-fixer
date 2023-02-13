class_name Generic_CHARGE extends Base_EnemyState

# next animator fsm node to travel to
export(String) var next_node = "ATTACK"


########################################################################
#Overrides
########################################################################
func on_enter() -> void:
	.on_enter()
	yield(get_tree().create_timer(1.6), "timeout")
	animator.travel(next_node)
