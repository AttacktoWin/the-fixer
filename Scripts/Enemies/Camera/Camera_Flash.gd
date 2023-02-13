extends Base_EnemyState


func on_exit():
	state_machine.is_flashON = true


func tick(_delta: float) -> void:
	#handle flash logic here
	pass
