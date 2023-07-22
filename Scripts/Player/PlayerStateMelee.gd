# Author: Marcus

class_name PlayerStateMelee extends FSMNode


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.FIRE_MELEE]


func enter():
	self.entity.melee_hitbox.attack_direction = self.entity.get_wanted_gun_vector().angle()
	self.entity.setv(LivingEntityVariable.VELOCITY, Vector2.ZERO)
	self.fsm.set_animation("MELEE")
	self.fsm.get_animation_player().playback_speed = self.entity.get_melee_attack_speed()
	Wwise.post_event_id(AK.EVENTS.SWING_KNUCKLES_PLAYER, Scene)


func on_anim_reached_end(_anim: String):
	self.fsm.get_animation_player().playback_speed = 1.0
	self.fsm.set_state(PlayerState.IDLE)


func exit():
	self.fsm.reset_animation()
