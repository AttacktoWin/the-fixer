extends Base_EnemyState

var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var jump_peak = Vector2.ZERO
var bezier_point = Vector2.ZERO

var timer = 0
var max_time = 0.6


func test(_delta):
	if animator.get_current_node() == "Get_In_Position":
		timer += _delta
		state_machine.position = start_pos.linear_interpolate(
			end_pos, timer / max_time
		)
		return false
	return true


func enter() -> void:
	.enter()
	animator.travel("Attack_CHARGE")

	start_pos = self.global_position
	end_pos = (-get_DirectionToPlayer(self) * 20) + start_pos
	print(end_pos)


func exit():
	animator.travel("Idle")


func physics_tick(_delta: float) -> void:
	if test(_delta):
		state_machine.transition_to("IDLE")


func _draw():
	if is_Active:
		pass
