extends Base_EnemyState


func tick(_delta: float) -> void:
	if animator.get_current_node() == "Idle":
		state_machine.transition_to("CHASE")


func enter() -> void:
	.enter()
	flipSprite()
	animator.travel("Attack_SLASH")


func exit():
	flipSprite()
	animator.travel("Chase_ON")


func _draw():
	if is_Active:
		pass
