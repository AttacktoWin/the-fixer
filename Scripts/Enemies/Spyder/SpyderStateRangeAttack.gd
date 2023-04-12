# Author: Marcus

class_name SpyderStateRangedAttack extends FSMNode

const MAX_DEVIATION = PI * 2  # omni
const COOLDOWN = 5
const COOLDOWN_INTERRUPT = 1.75
const SLOW_TIME = 1.75

var _charging: int = 2
var _angle: float = 0
var _cooldown_timer = 0

var _vfx_ring = null
var _vfx_particles = null
var _vfx_scale_node = null
var _timer = 0

const BASE_VFX_SCALE = 1.25


func get_handled_states():
	return [EnemyState.ATTACKING_RANGED]


func can_transition(_from):
	return (
		self._cooldown_timer <= 0
		and self.entity.has_target()
		and AI.has_LOS(self.global_position, self.entity.get_target().global_position)
	)


func initialize():
	self._vfx_ring = self.entity.flash_vfx.get_node("VFX_Ring")
	self._vfx_particles = self.entity.flash_vfx.get_node("Inner/Particles2D")
	self._vfx_scale_node = self.entity.flash_vfx.get_node("Inner")


func _background_physics(_delta):
	self._cooldown_timer -= _delta


func enter():
	self._timer = 0

	self._vfx_particles.emitting = true
	self._vfx_ring.modulate.a = 0.0
	self._vfx_scale_node.scale = Vector2.ZERO
	self.entity.flash_vfx.scale = Vector2.ONE * BASE_VFX_SCALE
	self.entity.flash_vfx.modulate.a = 1.0
	self.entity.flash_vfx.position.y = 0.0

	#Wwise.post_event_id(AK.EVENTS.CHARGE_SPYDER, self.entity)
	Wwise.post_event_id(AK.EVENTS.FLASH_SPYDER, self.entity)
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
		if not (body is LivingEntity) or not body.can_be_hit():
			continue

		if not AI.has_LOS(self.global_position, body.global_position):
			continue

		# apply slow
		var dist_norm = (
			(self.entity.global_position - body.global_position).length()
			/ (self.entity.ranged_attack_range)
		)
		if dist_norm > 1.0:
			continue
		var interp1 = MathUtils.interpolate(
			dist_norm, SLOW_TIME, SLOW_TIME * (3.0 / 4.0), MathUtils.INTERPOLATE_IN_EXPONENTIAL
		)
		body.status_timers.delta_timer(LivingEntityStatus.SLOWED, interp1)
		Scene.ui.get_node("FlashFeedback").add_value(interp1)


func _physics_process(delta):
	self._timer += delta
	if self._charging == 0:
		self.entity.flash_vfx.scale = (
			Vector2.ONE
			* MathUtils.interpolate(
				self._timer / 0.8,
				BASE_VFX_SCALE,
				BASE_VFX_SCALE * 2,
				MathUtils.INTERPOLATE_IN_EXPONENTIAL
			)
		)
		self.entity.flash_vfx.modulate.a = MathUtils.interpolate(
			self._timer / 0.8, 0.7, 0, MathUtils.INTERPOLATE_OUT
		)
		self.entity.flash_vfx.position.y = MathUtils.interpolate(
			(self._timer) / 0.8, 0, -200, MathUtils.INTERPOLATE_IN_EXPONENTIAL
		)
		return
	self._vfx_ring.modulate.a = MathUtils.interpolate(
		self._timer / 0.4, 0, 1, MathUtils.INTERPOLATE_IN_EXPONENTIAL
	)
	self._vfx_ring.scale = (
		MathUtils.TO_ISO
		* MathUtils.interpolate(self._timer / 0.7, 2, 1, MathUtils.INTERPOLATE_OUT)
	)
	self._vfx_scale_node.scale = (
		Vector2.ONE
		* MathUtils.interpolate(self._timer / 0.9, 0, 1, MathUtils.INTERPOLATE_OUT_EXPONENTIAL)
	)


func on_anim_reached_end(_anim: String):
	if not self.entity or not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return

	if self._charging == 2:
		#Wwise.post_event_id(AK.EVENTS.FLASH_SPYDER, self.entity)
		self._charging = 1
		self.fsm.set_animation("CHARGE")
		return

	if self._charging == 1:
		self._charging = 0
		self._timer = 0
		self.fsm.set_animation("FLASH")
		do_attack()
	else:
		if self.entity.has_target():
			self.fsm.set_state(EnemyState.CHASING)
		else:
			self.fsm.set_state(EnemyState.IDLE)


func exit():
	self._vfx_ring.modulate.a = 0.0
	self._vfx_scale_node.scale = Vector2.ZERO
	self._vfx_particles.emitting = false
	self.entity.disable_pathfind -= 1
	if self._cooldown_timer <= 0:
		self._cooldown_timer = COOLDOWN_INTERRUPT
