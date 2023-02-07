extends Base_State_Camera

var dir: Vector2 = Vector2.ZERO


func tick(_delta: float) -> void:
	var player = state_machine.context["player"]
	dir = player.global_position - self.global_position
	update()
	if dir.length() <= state_machine.context["attack_range"]:
		state_machine.transition_to("JUMP")


func physics_tick(_delta: float) -> void:
	move()


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


func move() -> void:
	# warning-ignore:UNUSED_VARIABLE
	var velocity = state_machine.context["kinematic_body"].move_and_slide(
		state_machine.context["speed"] * dir.normalized()
	)
