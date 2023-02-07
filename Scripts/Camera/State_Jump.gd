extends Base_State_Camera


func tick(_delta: float) -> void:
	update()


func physics_tick(_delta: float) -> void:
	jump(_delta)


var time = 0
var u = 100
var g = 10


func enter() -> void:
	pass


func jump(_delta) -> void:
	var v = Vector2.ZERO
	time += _delta
	v.x = 100
	v.y = -(76 - (76 * time))
	state_machine.context["kinematic_body"].move_and_slide(v)
