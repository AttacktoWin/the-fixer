extends Base_EnemyState

var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var jump_peak = Vector2.ZERO
var bezier_point = Vector2.ZERO

var timer = 0
var max_time = 0.6


func attack(_delta):
	if animator.get_current_node() == "Attack":
		timer += _delta
		state_machine.position = start_pos.linear_interpolate(
			end_pos, timer / max_time
		)


func transition_atAnimEnd():
	state_machine.transition_to("CHASE")


func enter() -> void:
	.enter()
	timer = 0
	animator.travel("Attack")

	start_pos = self.global_position
	end_pos = (get_DirectionToPlayer(self) * 150) + start_pos
	print(end_pos)


func physics_tick(_delta: float) -> void:
	attack(_delta)
