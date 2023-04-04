# Author: Marcus

class_name UmbrellaStateMelee extends FSMNode

var _charging: bool = true
var _pushing_disabled = false
var _current_time = 0
var _target_direction = Vector2.ZERO
var _last_position = Vector2.ZERO

const ATTACK_SPEED_MULTIPLIER = 3.5
const ATTACK_TIME = 1.4
const WARMUP_TIME = 0.2
const COOLDOWN_TIME = 1


func get_handled_states():
	return [EnemyState.ATTACKING_MELEE]


func enter():
	self.entity.disable_pathfind += 1
	self.entity.disable_pushing += 1
	self._current_time = 0.0
	self._pushing_disabled = true
	self.fsm.set_animation("TO_CLOSED")
	self._target_direction = (self.entity.get_target().global_position - self.entity.global_position).normalized()
	self.entity.setv(LivingEntityVariable.VELOCITY, Vector2.ZERO)
	var x = sign(self._target_direction.x)
	if x != 0:
		self.entity.flip_components.scale.x = -x


func on_anim_reached_end(anim: String):
	if anim == "TO_CLOSED":
		self.fsm.set_animation("SPIN")
	if anim == "SPIN":
		self.fsm.set_animation("IDLE_CLOSED")
	if anim == "TO_OPEN":
		if self.entity.has_target():
			self.fsm.set_state(EnemyState.CHASING)
		else:
			self.fsm.set_state(EnemyState.IDLE)


func state_is_interruptable():
	return self.fsm.get_animation() != "SPIN"


# very similar to beetle code
func _physics_process(delta):
	self._current_time += delta
	if self._current_time <= ATTACK_TIME:
		var multiplier = (
			self.entity.getv(LivingEntityVariable.MAX_SPEED)
			* ATTACK_SPEED_MULTIPLIER
			* MathUtils.interpolate(
				(self._current_time - WARMUP_TIME) / (ATTACK_TIME - WARMUP_TIME),
				0,
				1,
				MathUtils.INTERPOLATE_IN
			)
		)
		multiplier = max(multiplier, 0.1)
		self.entity.setv(LivingEntityVariable.VELOCITY, self._target_direction * multiplier)

		if self.fsm.get_animation() == "SPIN":
			self.entity.hitbox.invoke_attack()

		# check collide with walls
		if (
			max((self._last_position - self.entity.global_position).length(), 5)
			< multiplier / 1.1 * delta
		):
			self._current_time = ATTACK_TIME
			self.entity.setv(LivingEntityVariable.VELOCITY, Vector2.ZERO)

	else:
		if (
			self._current_time > ATTACK_TIME + COOLDOWN_TIME
			and self.fsm.get_animation() == "IDLE_CLOSED"
		):
			self.fsm.set_animation("TO_OPEN")

		self.entity.setv(
			LivingEntityVariable.VELOCITY, self.entity.getv(LivingEntityVariable.VELOCITY) * 0.94
		)
	self._last_position = self.entity.global_position
	self.entity._try_move()


func exit():
	self.entity.disable_pathfind -= 1
	if self._pushing_disabled:
		self.entity.disable_pushing -= 1
	self.entity.set_height(0)
