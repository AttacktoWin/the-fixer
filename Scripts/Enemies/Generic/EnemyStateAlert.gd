# Author: Marcus

class_name EnemyStateAlert extends FSMNode

export var animation_name: String = "ALERTED"
export(AK.EVENTS._dict) var alert_sound: int = -1


func get_handled_states():
	return [EnemyState.ALERTED]


func enter():
	if self.alert_sound:
		Wwise.post_event_id(self.alert_sound, Scene)
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, false)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_LINE_COLOR, Constants.COLOR.YELLOW)
	self.fsm.set_animation(animation_name)


func on_anim_reached_end(_anim: String):
	self.fsm.set_state(EnemyState.CHASING)


func exit():
	pass
