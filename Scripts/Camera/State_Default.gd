extends Base_State_Camera


func tick(_delta: float) -> void:
	update()
	if sensePlayer():
		state_machine.transition_to("CHASE")


func _draw():
	if on:
		draw_circle(
			Vector2.ZERO,
			state_machine.context["sense_radius"],
			Color.red - Color(0, 0, 0, 0.5)
		)


func sensePlayer() -> bool:
	var dist := self.global_position.distance_to(
		state_machine.context["player"].global_position
	)
	if dist <= state_machine.context["sense_radius"]:
		return true
	return false
