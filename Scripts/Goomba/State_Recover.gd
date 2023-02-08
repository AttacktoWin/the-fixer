extends Base_State_Goomba

var timer = 0
var transitioned = false


func tick(_delta: float) -> void:
	update()


func enter() -> void:
	print("entered")
	print("pev: " + state_machine.context["prev"])
	on = true
	timer = 0
	recoverAnim()


func physics_tick(_delta: float) -> void:
	if slide(_delta):
		state_machine.transition_to("DEFAULT")
		pass


func exit() -> void:
	on = false
	emit_signal("ready_to_transition")


func recoverAnim() -> void:
	if state_machine.context["animator"].current_animation != "Recover":
		state_machine.context["animator"].play("Recover")


func slide(_delta: float) -> bool:
	timer += _delta
	if timer < 0.4:
		# warning-ignore:UNUSED_VARIABLE
		var velocity = state_machine.context["kinematic_body"].move_and_slide(
			(
				lerp(60, 0, clamp(timer / 0.4, 0, 1))
				* state_machine.context["recovery_dir"]
			)
		)
		return false
	return true
