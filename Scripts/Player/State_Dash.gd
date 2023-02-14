class_name PlayerState_Dash extends Base_State


func on_enter(_msg: Dictionary = {}) -> void:
	.on_enter(_msg)
	state_machine.animator.travel("Dash")
	state_machine._setv(LivingEntity.VARIABLE.VELOCITY, Vector2.ZERO)


func finish_dash() -> void:
	state_machine.transition_to("FREE")


func on_exit() -> void:
	.on_exit()
