# Author: Marcus

class_name EnemyStateAlert extends FSMNode


func get_handled_states():
	return [EnemyState.ALERTED]


func enter():
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, false)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_LINE_COLOR, Constants.COLOR.YELLOW)
	self.fsm.set_animation("ALERTED")


func on_anim_reached_end():
	self.fsm.set_state(EnemyState.CHASING)


func exit():
	pass