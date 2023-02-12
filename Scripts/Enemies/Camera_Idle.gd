extends Base_EnemyState


# Description: detect player when in range
func sensePlayer() -> bool:
	if is_PlayerInRange(self, state_machine.sense_radius):
		return true
	return false


########################################################################
#Overrides
########################################################################
func enter() -> void:
	.enter()
	animator.travel("Idle")


func exit():
	flipSprite()
	animator.travel("Alerted")


func tick(_delta: float) -> void:
	update()
	if sensePlayer():
		state_machine.transition_to("CHASE")


func _draw():
	draw_circle(
		Vector2.ZERO,
		state_machine.sense_radius,
		Color.red - Color(0, 0, 0, 0.5)
	)
