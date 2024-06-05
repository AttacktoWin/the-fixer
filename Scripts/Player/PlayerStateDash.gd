# Author: Marcus

class_name PlayerStateDash extends FSMNode

var _dash_recharge_timer: float = 0
var _dash_timer: float = 0.25
var _dash_direction: Vector2 = Vector2()
var _gun_angle: float = -1
var _gun_counter: float = 0
var _has_dashed = false

const DASH_COOLDOWN = 0.3
const DASH_GUN_ANGLE = 0.8
const DASH_INVULNERABILITY = 0.5


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.DASHING]


func can_transition(_from):
	return self._dash_recharge_timer <= 0


func enter():
	self.entity.status_timers.delta_timer(LivingEntityStatus.INVULNERABLE, DASH_INVULNERABILITY)
	self.entity.set_collision_mask_bit(3, false)
	self._gun_angle = MathUtils.abs_x(self.entity.get_wanted_gun_vector()).angle()
	self._gun_counter = 0
	Wwise.post_event_id(AK.EVENTS.DODGE_PLAYER, Scene)
	self.fsm.set_animation("DASH")
	self.entity.setv(LivingEntityVariable.VELOCITY, Vector2())
	CameraSingleton.set_zoom(Vector2(1.01, 1.01))
	self._has_dashed = false
	self._dash_timer = 0.25


func _update_dash_direction():
	var v = self.entity.get_wanted_direction()
	if v:
		if Scene.is_controller():
			if v.length() > 0.25:
				self._dash_direction = v.normalized()
		else:
			self._dash_direction = v


func _dash_increment(_delta):
	_update_dash_direction()
	CameraSingleton.set_zoom(Vector2(0.97, 0.97))
	CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM)
	CameraSingleton.set_zoom(Vector2(1, 1))
	var old_pos = self.entity.global_position
	self.entity.move_and_slide(self._dash_direction * 320 * 60)
	self.entity.set_collision_mask_bit(3, true)

	if self.entity.move_and_collide(Vector2(0, 0), true, true, true):
		self.entity.global_position = old_pos
		self.entity.move_and_slide(self._dash_direction * 320 * 60)
	self._has_dashed = true


func on_anim_reached_end(_anim: String):
	self.fsm.set_state(PlayerState.IDLE)


func exit():
	self._dash_recharge_timer = DASH_COOLDOWN
	self.fsm.reset_animation()


func _background_physics(delta):
	self._dash_recharge_timer -= delta
	_update_dash_direction()


func _physics_process(delta):
	self._dash_timer -= delta
	if self._dash_timer < 0 and not self._has_dashed:
		_dash_increment(delta)


func _process(delta):
	self._gun_counter += delta
	var ang = 0
	if self._gun_counter > 0.3:
		ang = MathUtils.interpolate(
			(self._gun_counter - 0.3) * 10,
			DASH_GUN_ANGLE,
			MathUtils.abs_x(self.entity.get_wanted_gun_vector()).angle(),
			MathUtils.INTERPOLATE_IN
		)
	else:
		ang = MathUtils.interpolate(
			self._gun_counter * 10, self._gun_angle, DASH_GUN_ANGLE, MathUtils.INTERPOLATE_IN
		)
	self.entity.set_gun_angle(ang)
