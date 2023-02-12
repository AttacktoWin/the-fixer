extends Base_EnemyState


func chasePlayer() -> bool:
	if is_PlayerInRange(self, state_machine.attack_range):
		return true

	if animator.get_current_node() == "Chase_ON":
		# warning-ignore:UNUSED_VARIABLE
		var velocity = state_machine.move_and_slide(
			state_machine.speed * get_DirectionToPlayer(self)
		)
	return false


########################################################################
#Overrides
########################################################################
func tick(_delta: float) -> void:
	flipSprite()
	if chasePlayer():
		state_machine.transition_to("CHARGE")


func _draw():
	if is_Active:
		draw_line(Vector2.ZERO, get_PlayerInLocal(self), Color.white)
		draw_line(
			Vector2.ZERO,
			get_DirectionToPlayer(self) * state_machine.attack_range,
			Color.blue,
			4
		)
