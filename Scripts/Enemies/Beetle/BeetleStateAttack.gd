# Author: Marcus

class_name BeetleStateAttack extends FSMNode

var _charging: bool = true
var _current_time = 0
var _pushing_disabled = false
var _wait_timer = 0
var _target_direction = Vector2.ZERO
var _last_position = Vector2.ZERO

const ATTACK_SPEED_MULTIPLIER = 3.5
const ATTACK_TIME = 2
const COOLDOWN_TIME = 0.5
const RANDOM_MAX = 32
const WAIT_TIME = 0.4


func get_handled_states():
	return [EnemyState.ATTACKING_MELEE]


func enter():
	self.entity.disable_pathfind += 1
	self.entity.disable_pushing += 1
	self._pushing_disabled = true
	self.fsm.set_animation("IDLE")
	self._charging = true
	self._current_time = 0.0
	self._wait_timer = WAIT_TIME
	self._target_direction = (self.entity.get_target().global_position - self.entity.global_position).normalized()
	self._last_position = self.entity.global_position
	var x = sign(self._target_direction.x)
	if x != 0:
		self.entity.flip_components.scale.x = -x


func state_is_interruptable():
	return self._wait_timer > 0 or self._current_time > ATTACK_TIME


func _physics_process(delta):
	if self._wait_timer > 0:
		self.entity.setv(
			LivingEntityVariable.VELOCITY, self.entity.getv(LivingEntityVariable.VELOCITY) * 0.86
		)
		self._wait_timer -= delta
		if self._wait_timer <= 0:
			self.fsm.set_animation("CHARGE")
		return

	self._current_time += delta
	if self._current_time <= ATTACK_TIME:
		var multiplier = (
			self.entity.getv(LivingEntityVariable.MAX_SPEED)
			* ATTACK_SPEED_MULTIPLIER
			* MathUtils.interpolate(self._current_time * 2, 0, 1, MathUtils.INTERPOLATE_IN_BACK)
		)
		self.entity.setv(LivingEntityVariable.VELOCITY, self._target_direction * multiplier)
		self.fsm.get_animation_player().playback_speed = clamp(
			multiplier / self.entity.getv(LivingEntityVariable.MAX_SPEED) * 10,
			-ATTACK_SPEED_MULTIPLIER,
			ATTACK_SPEED_MULTIPLIER
		)

		if multiplier > 1:
			self.entity.hitbox.invoke_attack()

		# check collide with walls
		if (
			(
				max((self._last_position - self.entity.global_position).length(), 5)
				< multiplier / 1.1 * delta
			)
			and self._current_time > 0.6
		):
			Wwise.post_event_id(AK.EVENTS.CRASH_BEETLE, self.entity)
			CameraSingleton.shake(128)
			self._current_time = ATTACK_TIME
			self.entity.setv(LivingEntityVariable.VELOCITY, Vector2.ZERO)

	else:
		self.entity.setv(
			LivingEntityVariable.VELOCITY, self.entity.getv(LivingEntityVariable.VELOCITY) * 0.86
		)
		self.fsm.get_animation_player().playback_speed = clamp(
			(
				self.entity.getv(LivingEntityVariable.VELOCITY).length()
				/ self.entity.getv(LivingEntityVariable.MAX_SPEED)
			),
			-ATTACK_SPEED_MULTIPLIER,
			ATTACK_SPEED_MULTIPLIER
		)
		if self._current_time > ATTACK_TIME + COOLDOWN_TIME:
			if self.entity.has_target():
				self.fsm.set_state(EnemyState.CHASING)
			else:
				self.fsm.set_state(EnemyState.IDLE)
	self._last_position = self.entity.global_position
	self.entity._try_move()


func exit():
	self.entity.disable_pathfind -= 1
	if self._pushing_disabled:
		self.entity.disable_pushing -= 1
	self.entity.set_height(0)
