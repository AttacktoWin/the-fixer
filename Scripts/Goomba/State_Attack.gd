extends Base_State_Goomba

var timer = 0


func tick(_delta: float) -> void:
	update()
	if attackPlayer():
		state_machine.transition_to("CHASE")


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
			Color.green - Color(0, 0, 0, 0.5)
		)


#TODO: change the timer to work with animation
func attackPlayer() -> bool:
	if timer < 60:
		timer += 1
		return false
	timer = 0
	return true
