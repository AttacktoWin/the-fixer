# Author: Marcus

class_name PlayerStateMelee extends FSMNode


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.FIRE_MELEE]


func enter():
	var dir = CameraSingleton.get_mouse_from_camera_center_screen().normalized().angle()
	self.entity.melee_hitbox.attack_direction = dir
	self.entity.setv(LivingEntityVariable.VELOCITY, Vector2.ZERO)
	self.fsm.set_animation("MELEE")
	Wwise.post_event_id(AK.EVENTS.SWING_KNUCKLES_PLAYER, self.entity)


func on_anim_reached_end():
	self.fsm.set_state(PlayerState.IDLE)
