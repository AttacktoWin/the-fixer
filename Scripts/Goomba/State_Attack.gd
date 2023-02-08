extends Base_State_Goomba

var a = Vector2.ZERO
var b = Vector2.ZERO
var h = Vector2.ZERO
var z = Vector2.ZERO
var g
var timer = 0
var t = 0.7

var transitioned = false


func tick(_delta: float) -> void:
	update()
	#state_machine.transition_to("CHASE")


func physics_tick(_delta: float) -> void:
	var ret = attackPlayer(_delta)
	if ret == true and transitioned == false:
		state_machine.transition_to("RECOVER")


func enter() -> void:
	print("pev: " + state_machine.context["prev"])
	a = self.position
	g = self.global_position
	b = (
		((state_machine.context["player"].global_position) - self.global_position).normalized()
		* 150
	)
	var angle = self.get_angle_to(self.to_global(b))
	h = Vector2(30 * cos(angle), 30 * sin(angle)) + Vector2(0, -50)
	timer = 0
	on = true
	transitioned = false


func exit() -> void:
	on = false
	transitioned = true
	yield(get_tree(), "idle_frame")
	emit_signal("ready_to_transition")


func _draw():
	if on:
		draw_circle(
			Vector2.ZERO,
			state_machine.context["attack_range"],
			Color.green - Color(0, 0, 0, 0.5)
		)
		#target
		draw_circle(b, 10, Color.red - Color(0, 0, 0, 0.5))
		#intrim circle
		draw_circle(Vector2(0, -50), 30, Color.blue - Color(0, 0, 0, 0.5))
		#intrim
		draw_circle(h, 10, Color.yellow - Color(0, 0, 0, 0.5))
		#final
		draw_circle(z, 10, Color.white)
		draw_line(
			Vector2.ZERO,
			self.to_local(state_machine.context["player"].global_position),
			Color.white
		)


#Highlevel idea
#there is a starting point, an end point and a height i want to reach.
#i know that one way i can touch all three points in a curve is through a quad bezier curve
#the third point is in flux tho
#at 0deg its in the center of the segment
#at 90deg its somewhere closer to the start point since thats what a jump would look like in perspective
#i could use a circle? hard to describe with words
func attackPlayer(_delta: float):
	if state_machine.context["animator"].current_animation != "Attack":
		state_machine.context["animator"].play("Attack", -1, 1 / 5.67)

	timer += _delta
	var x = lerp(a + g, h + g, clamp(timer / t, 0, 1))
	var y = lerp(h + g, b + g, clamp(timer / t, 0, 1))
	z = lerp(x, y, clamp(timer / t, 0, 1))
	state_machine.context["kinematic_body"].position = z
	state_machine.context["recovery_dir"] = (b - a).normalized()
	if timer >= t:
		return true
	return false
