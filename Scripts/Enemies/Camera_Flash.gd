extends Base_EnemyState


func tick(_delta: float) -> void:
	if animator.get_current_node() == "Idle":
		state_machine.transition_to("CHASE")


func enter() -> void:
	flipSprite()
	animator.travel("Attack_FLASH")


func exit():
	flipSprite()
	animator.travel("Chase_ON")
