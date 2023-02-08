extends Base_State_Goomba

var transitioned = false


func tick(_delta: float) -> void:
	update()
	if sensePlayer() and transitioned == false:
		flipSprite()
		animateFound()
		state_machine.transition_to("CHASE")


func enter() -> void:
	.enter()
	transitioned = false
	state_machine.context["animator"].play("Default")


func exit() -> void:
	animateFound()
	transitioned = true
	on = false


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


func flipSprite():
	var angle := rad2deg(
		self.get_angle_to(state_machine.context["player"].global_position)
	)
	if angle < 90 and angle > -90:
		state_machine.context["sprite"].flip_h = true
	else:
		state_machine.context["sprite"].flip_h = false


func animateFound():
	if state_machine.context["animator"].current_animation != "Found":
		state_machine.context["animator"].play("Found")
		yield(state_machine.context["animator"], "animation_finished")
		emit_signal("ready_to_transition")
