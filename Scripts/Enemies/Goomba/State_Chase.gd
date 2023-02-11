# Author: Yalmaz
# Description: Chase state for goomba has it run after the player.
extends Base_State_Goomba


func chasePlayer() -> bool:
	if p_manager.is_PlayerInRange(
		self.global_position, p_context.attack_radius
	):
		return true

	# warning-ignore:UNUSED_VARIABLE
	var velocity = p_context.kinematic_body.move_and_slide(
		p_context.speed * p_manager.get_DirectionToPlayer(self.global_position)
	)
	animateChase()
	return false


func animateChase():
	if p_context.animator.current_animation != "Chase":
		p_context.animator.play("Chase")


func animateCharge():
	if p_context.animator.current_animation != "Charge_Attack":
		p_context.animator.play("Charge_Attack")
		yield(p_context.animator, "animation_finished")
		emit_signal("cleanup_finished")


########################################################################
#Overrides
########################################################################
func enter(_context) -> void:
	.enter(_context)
	is_cleaningUp = false


func exit():
	animateCharge()
	is_cleaningUp = true
	return .exit()


func tick(_delta: float) -> void:
	flipSprite()
	if chasePlayer() and is_cleaningUp == false:
		state_machine.transition_to("ATTACK")

########################################################################
#DEBUG
########################################################################
# Description: Draw debug visuals
# func _draw():
# 	if not is_cleaningUp:
# 		draw_line(Vector2.ZERO, p_manager.get_PlayerInLocal(self), Color.white)
# 		draw_circle(
# 			Vector2.ZERO,
# 			p_context.attack_radius,
# 			Color.blue - Color(0, 0, 0, 0.5)
# 		)
