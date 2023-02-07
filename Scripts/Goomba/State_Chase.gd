extends Base_State_Goomba


func tick(_delta: float) -> void:
	update()
	if chasePlayer():
		state_machine.transition_to("ATTACK")


func enter() -> void:
	on = true


func exit() -> void:
	on = false


func _draw():
	if on:
		draw_line(
			Vector2.ZERO,
			self.to_local(state_machine.context["player"].global_position),
			Color.white
		)

		draw_circle(
			Vector2.ZERO,
			state_machine.context["attack_range"],
			Color.blue - Color(0, 0, 0, 0.5)
		)


func chasePlayer() -> bool:
	var player = state_machine.context["player"]
	var dir = player.global_position - self.global_position
	if dir.length() <= state_machine.context["attack_range"]:
		return true

	# warning-ignore:UNUSED_VARIABLE
	var velocity = state_machine.context["kinematic_body"].move_and_slide(
		state_machine.context["speed"] * dir.normalized()
	)
	return false
