extends Base_EnemyState


func enter() -> void:
	.enter()
	yield(get_tree().create_timer(1.6), "timeout")
	state_machine.transition_to("ATTACK")


func _draw():
	if is_Active:
		pass
