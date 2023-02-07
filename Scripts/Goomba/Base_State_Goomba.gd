class_name Base_State_Goomba extends Base_State

var on = false


func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("ui_right"):
		state_machine.transition_to("STAGGER")
