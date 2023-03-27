# Author: Marcus

class_name SpyderStateRangedAttack extends FSMNode

const MAX_DEVIATION = PI / 6
const COOLDOWN = 5
const COOLDOWN_INTERRUPT = 1

var _charging: int = 2
var _angle: float = 0
var _cooldown_timer = 0


func get_handled_states():
	return [EnemyState.ATTACKING_RANGED]


func can_transition(_from):
	return self._cooldown_timer <= 0


func _background_physics(_delta):
	self._cooldown_timer -= _delta


func enter():
	self.entity.disable_pathfind += 1
	self.fsm.set_animation("CHARGE_TRANSITION")
	self._charging = 2
	self._angle = (self.entity.global_position - self.entity.get_target().global_position).angle()
	var x = sign((self.entity.global_position - self.entity.get_target().global_position).x)
	if x != 0:
		self.entity.flip_components.scale.x = x


func do_attack():
	self._cooldown_timer = COOLDOWN
	var collider = self.entity.get_node("RangedAttack")
	for body in collider.get_overlapping_bodies():
		if not (body is LivingEntity):
			continue
		var ang = (self.entity.global_position - body.global_position).angle()
		var diff = abs(MathUtils.angle_difference(ang, self._angle))
		if diff > MAX_DEVIATION:
			continue


func on_anim_reached_end():
	if not self.entity or not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return

	if self._charging == 2:
		self._charging = 1
		self.fsm.set_animation("CHARGE")
		return

	if self._charging == 1:
		self._charging = 0
		self.fsm.set_animation("FLASH")
		do_attack()
	else:
		if self.entity.has_target():
			self.fsm.set_state(EnemyState.CHASING)
		else:
			self.fsm.set_state(EnemyState.IDLE)


func exit():
	self.entity.disable_pathfind -= 1
	if self._cooldown_timer <= 0:
		self._cooldown_timer = COOLDOWN_INTERRUPT
