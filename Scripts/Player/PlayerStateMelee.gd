# Author: Marcus

class_name PlayerStateMelee extends FSMNode


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.FIRE_MELEE]


func enter():
	var vec = self.entity.get_wanted_gun_vector(false)
	self.entity.visual.scale.x = sign(vec.x) if vec.x != 0.0 else 1.0
	self.entity.melee_hitbox.attack_direction = vec.angle()
	self.entity.setv(LivingEntityVariable.VELOCITY, vec.normalized() * self.entity.get_melee_push())
	self.fsm.set_animation("MELEE")
	self.fsm.get_animation_player().playback_speed = self.entity.get_melee_attack_speed()
	Wwise.post_event_id(AK.EVENTS.SWING_KNUCKLES_PLAYER, Scene)

func _physics_process(delta):
	var frames = MathUtils.delta_frames(delta)
	var fac = pow(0.9, frames)
	var current = self.entity.getv(LivingEntityVariable.VELOCITY)
	current *= fac
	self.entity.setv(LivingEntityVariable.VELOCITY, current)

func on_anim_reached_end(_anim: String):
	self.fsm.get_animation_player().playback_speed = 1.0
	self.fsm.set_state(PlayerState.IDLE)


func exit():
	self.fsm.reset_animation()
