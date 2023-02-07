extends Base_State_Goomba

export(int) var attack_radius = 80
export(int) var speed = 100

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
		draw_circle(Vector2.ZERO, attack_radius, Color.white)


func attackPlayer() -> bool:
	if timer < 60:
		timer += 1
		return false
	timer = 0
	return true
