# Author: Marcus

class_name EnemeyStateAlert extends FSMNode


func get_handled_states():
	return [EnemyState.ALERTED]


func enter():
	self.fsm.set_animation("ALERT")


func on_anim_reached_end():
	self.fsm.set_state()


func exit():
	pass
