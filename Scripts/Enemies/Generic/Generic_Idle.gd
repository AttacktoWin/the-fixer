class_name Generic_IDLE extends Base_EnemyState

# next animator fsm node to travel to
export(String) var next_node = "ALERTED"


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
	animator.travel("IDLE")


func tick(_delta: float) -> void:
	if sensePlayer():
		flipSprite()
		animator.travel(next_node)


########################################################################
#DEBGU CODE
########################################################################
func _draw():
	if is_Active:
		draw_circle(
			Vector2.ZERO,
			state_machine.sense_radius,
			Color.red - Color(0, 0, 0, 0.5)
		)
