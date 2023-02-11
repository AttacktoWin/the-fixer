# Author: Yalmaz
# Description: Chase state for goomba has it run after the player.
extends Base_State_Goomba

var timer = 0


func recoverAnim() -> void:
	if p_context.animator.current_animation != "Recover":
		p_context.animator.play("Recover")


func slide(_delta: float) -> bool:
	timer += _delta
	if timer < 0.4:
		# warning-ignore:UNUSED_VARIABLE
		var velocity = p_context.kinematic_body.move_and_slide(
			(
				lerp(60, 0, clamp(timer / 0.4, 0, 1))
				* p_context.extra["recovery_dir"]
			)
		)
		return false
	return true


########################################################################
#Overrides
########################################################################
func tick(_delta: float) -> void:
	update()


func physics_tick(_delta: float) -> void:
	if slide(_delta):
		state_machine.transition_to("DEFAULT")
		pass


func exit():
	emit_signal("cleanup_finished")
	return .exit()


func enter(_context) -> void:
	.enter(_context)
	timer = 0
	recoverAnim()
