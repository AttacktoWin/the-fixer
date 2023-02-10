# Author: Yalmaz
# Description: Default state for the goomba where it isnt aware of the player. Implements Base_State_Goomba.
extends Base_State_Goomba


# Description: detect player when in range
func sensePlayer() -> bool:
	if p_manager.is_PlayerInRange(self.global_position, p_context.sense_radius):
		return true
	return false


# Description: method used to trigger startle animation
func animateFound():
	if p_context.animator.current_animation != "Found":
		p_context.animator.play("Found")
		yield(p_context.animator, "animation_finished")
		emit_signal("cleanup_finished")


########################################################################
#Overrides
########################################################################
func enter(_context) -> void:
	.enter(_context)
	is_cleaningUp = false
	p_context.animator.play("Default")


func exit():
	animateFound()
	is_cleaningUp = true
	return .exit()


func tick(_delta: float) -> void:
	if sensePlayer() and is_cleaningUp == false:
		flipSprite()
		animateFound()
		# state_machine.transition_to("CHASE")

########################################################################
#DEBUG
########################################################################
# Description: Draw debug visuals
# func _draw():
# 	if not is_cleaningUp:
# 		draw_circle(
# 			Vector2.ZERO,
# 			p_context.sense_radius,
# 			Color.red - Color(0, 0, 0, 0.5)
# 		)
