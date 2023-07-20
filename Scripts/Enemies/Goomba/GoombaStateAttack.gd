# Author: Marcus

class_name GoombaStateAttack extends FSMNode

var _charging: bool = true
var _current_time = 0
var _pushing_disabled = false

const ATTACK_TIME = 2
const JUMP_TIME = 0.8
const ATTACK_SPEED = 300
const ATTACK_DECAY = 0.92
const RANDOM_MAX = 16
const ATTACK_HEIGHT = 32


func get_handled_states():
	return [EnemyState.ATTACKING_MELEE]


func enter():
	self.entity.disable_pathfind += 1
	self.entity.disable_pushing += 1
	self._pushing_disabled = true
	self.fsm.set_animation("CHARGE")
	self._charging = true
	self._current_time = 0.0


func _physics_process(delta):
	if not self._charging:
		self._current_time += delta
	if self._current_time > JUMP_TIME or self._charging:
		self.entity.setv(
			LivingEntityVariable.VELOCITY,
			self.entity.getv(LivingEntityVariable.VELOCITY) * ATTACK_DECAY
		)
		if self._pushing_disabled:
			self._pushing_disabled = false
			self.entity.disable_pushing -= 1
	if self._current_time > ATTACK_TIME:
		if self.entity.has_target():
			self.fsm.set_state(EnemyState.CHASING)
		else:
			self.fsm.set_state(EnemyState.IDLE)

	var amount = abs(self._current_time - (JUMP_TIME / 2)) / (JUMP_TIME / 2)
	self.entity.set_height(
		MathUtils.interpolate(amount, ATTACK_HEIGHT, 0, MathUtils.INTERPOLATE_IN_QUAD)
	)

	var x = -sign(self.entity.getv(LivingEntityVariable.VELOCITY).x)
	if x != 0:
		self.entity.flip_components.scale.x = x

	self.entity._try_move()


func on_anim_reached_end(_anim: String):
	if not self.entity or not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return

	if self._charging:
		Wwise.post_event_id(AK.EVENTS.ATTACK_PILLBUG, Scene)
		self._charging = false
		self.fsm.set_animation("ATTACK")
		var off = Vector2(rand_range(-RANDOM_MAX, RANDOM_MAX), rand_range(-RANDOM_MAX, RANDOM_MAX))
		var dir = (self.entity.get_target().global_position - self.entity.global_position + off).normalized()
		self.entity.setv(LivingEntityVariable.VELOCITY, dir * ATTACK_SPEED)


func exit():
	self.entity.hitbox.get_child(0).disabled = true
	self.entity.disable_pathfind -= 1
	if self._pushing_disabled:
		self.entity.disable_pushing -= 1
	self.entity.set_height(0)
