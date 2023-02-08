extends Base_State_Goomba

var transitioned = false


func tick(_delta: float) -> void:
	update()
	flipSprite()
	if chasePlayer() and transitioned == false:
		state_machine.transition_to("ATTACK")


func enter() -> void:
	.enter()
	transitioned = false


func exit() -> void:
	animateCharge()
	on = false
	transitioned = true


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
	animateChase()
	return false


func flipSprite():
	var angle := rad2deg(
		self.get_angle_to(state_machine.context["player"].global_position)
	)
	if angle < 90 and angle > -90:
		state_machine.context["sprite"].flip_h = true
	else:
		state_machine.context["sprite"].flip_h = false


func animateChase():
	if state_machine.context["animator"].current_animation != "Chase":
		state_machine.context["animator"].play("Chase")


func animateCharge():
	if state_machine.context["animator"].current_animation != "Charge":
		state_machine.context["animator"].play("Charge")
		yield(state_machine.context["animator"], "animation_finished")
		emit_signal("ready_to_transition")
