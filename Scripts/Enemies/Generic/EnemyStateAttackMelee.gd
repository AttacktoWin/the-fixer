# Author: Marcus

class_name EnemyStateAttackMelee extends FSMNode

export var should_play_sound: bool = true
export(AK.EVENTS._dict) var play_sound = 0

var _charging: bool = true
var _pushing_disabled: bool = false

export var should_charge: bool = true
export var should_diable_pushing: bool = true


func get_handled_states():
	return [EnemyState.ATTACKING_MELEE]


func enter():
	self.entity.disable_pathfind += 1
	if should_diable_pushing:
		self.entity.disable_pushing -= 1
		self._pushing_disabled = true
	self._charging = true
	if self.fsm.has_animation("CHARGE") and self.should_charge:
		self.fsm.set_animation("CHARGE")
	else:
		self._charging = false
		self.fsm.set_animation("ATTACK_MELEE")
	self.entity.setv(LivingEntityVariable.VELOCITY, Vector2())


func _physics_process(_delta):
	self.entity._try_move()


func on_anim_reached_end():
	if not self.entity or not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return

	if self._charging:
		if self.should_play_sound:
			Wwise.post_event_id(self.play_sound, self.entity)
		self._charging = false
		self.fsm.set_animation("ATTACK_MELEE")
	else:
		if self.entity.has_target():
			self.fsm.set_state(EnemyState.CHASING)
		else:
			self.fsm.set_state(EnemyState.IDLE)


func exit():
	self.entity.disable_pathfind -= 1
	if self._pushing_disabled:
		self.entity.disable_pushing -= 1
