# Author: Yalmaz
# Description: Chase state for goomba has it run after the player.
extends Base_State_Goomba

var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var jump_peak = Vector2.ZERO
var bezier_point = Vector2.ZERO
var timer = 0
var max_time = 0.7


func attackPlayer(_delta: float):
	#Highlevel idea
	#there is a starting point, an end point and a height i want to reach.
	#i know that one way i can touch all three points in a curve is through a quad bezier curve
	#the third point is in flux tho
	#at 0deg its in the center of the segment
	#at 90deg its somewhere closer to the start point since thats what a jump would look like in perspective
	#i could use a circle? hard to describe with words
	if p_context.animator.current_animation != "Attack":
		p_context.animator.play("Attack", -1, 1 / 5.67)

	timer += _delta
	var x = lerp(start_pos, jump_peak, clamp(timer / max_time, 0, 1))
	var y = lerp(jump_peak, end_pos + start_pos, clamp(timer / max_time, 0, 1))
	bezier_point = lerp(x, y, clamp(timer / max_time, 0, 1))
	p_context.kinematic_body.position = bezier_point
	p_context.extra["recovery_dir"] = (end_pos).normalized()
	if timer >= max_time:
		return true
	return false


func waitForCleanup():
	is_cleaningUp = true
	yield(get_tree(), "idle_frame")
	emit_signal("cleanup_finished")


########################################################################
#Overrides
########################################################################
func physics_tick(_delta: float) -> void:
	var ret = attackPlayer(_delta)
	if ret == true and is_cleaningUp == false:
		state_machine.transition_to("RECOVER")


func enter(_context) -> void:
	.enter(_context)
	start_pos = self.global_position
	end_pos = (
		p_manager.get_DirectionToPlayer(start_pos)
		* p_context.lunge_distance
	)
	var angle = self.get_angle_to(self.to_global(end_pos))
	jump_peak = (
		Vector2(
			p_context.lunge_perpective * cos(angle),
			p_context.lunge_perpective * sin(angle)
		)
		+ Vector2(0, -p_context.lunge_height)
		+ self.global_position
	)
	timer = 0
	is_cleaningUp = false


func exit():
	waitForCleanup()
	return .exit()
