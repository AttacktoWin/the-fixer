# Author: Marcus

class_name UmbrellaStateRangedAttack extends EnemyStateMoving

export var bullet_speed: float = 350
export var bullet_damage: int = 10

var _current_angle = 0
var _angle_mult = 1
var _los_counter = 0

var _weapon_state = 0
var _weapon_cooldown = 0
var _shoot_timer = 0
var _shoot_counter = 0

const ANGLE_INCREASE = 1.4
const FOLLOW_DISTANCE_FAC = 1.0
const MAX_LOS_WAIT = 0.5
const WEAPON_COOLDOWN = 1.25
const FIRE_COOLDOWN = 0.5
const SHOTS_PER_VOLLEY = 3

var BulletScene = preload("res://Scenes/Weapons/BulletScene.tscn")


func get_handled_states():
	return [EnemyState.ATTACKING_RANGED]


func enter():
	self._shoot_counter = 0
	self._shoot_timer = FIRE_COOLDOWN
	self._weapon_state = 0
	self._weapon_cooldown = WEAPON_COOLDOWN + rand_range(0.25, 1)
	self._los_counter = 0
	self.entity.disable_pathfind += 1
	self._current_angle = (self.entity.global_position - self.entity.get_target().global_position).angle()


func _face_target():
	var from_target = self.entity.global_position - self.entity.get_target().global_position
	var x = sign(from_target.x)
	if x != 0:
		self.entity.flip_components.scale.x = x


func is_vulnerable():
	return self._weapon_state != 0


func _shoot():
	var bullet: BulletBase = BulletScene.instance().set_damage_source(self.entity)
	Scene.runtime.add_child(bullet)
	bullet.global_position = self.entity.socket_muzzle.global_position
	# I am unsure of why the to_iso call is necessary
	bullet.setv(
		AttackVariable.DIRECTION,
		MathUtils.to_iso(self.entity.get_target().global_position - bullet.global_position).angle()
	)
	bullet.setv(AttackVariable.SPEED, self.bullet_speed)
	bullet.setv(AttackVariable.DAMAGE, self.bullet_damage)
	Wwise.post_event_id(AK.EVENTS.ATTACK_PILLBUG, self.entity)


func _handle_weapon(delta):
	self._weapon_cooldown -= delta
	if self._weapon_cooldown < 0:
		if self._weapon_state == 0:
			if self.fsm.is_animation_complete():
				self._weapon_state = 1
			self.fsm.set_animation("TO_CLOSED")

		if self._weapon_state == 1:
			if self._shoot_counter >= SHOTS_PER_VOLLEY:
				if self.fsm.is_animation_complete():
					self._weapon_cooldown = WEAPON_COOLDOWN
					self._weapon_state = 0
					self._shoot_counter = 0
					self._shoot_timer = FIRE_COOLDOWN
				return

			self.fsm.set_animation("IDLE_CLOSED")
			self._shoot_timer -= delta

			if self._shoot_timer < 0:
				self._shoot_timer += FIRE_COOLDOWN
				self.entity.setv(LivingEntityVariable.VELOCITY, Vector2())
				self._shoot_counter += 1
				self._shoot()
				if self._shoot_counter >= SHOTS_PER_VOLLEY:
					#self.fsm.set_animation("TO_OPEN")
					self.fsm.set_state(EnemyState.ATTACKING_MELEE)

	else:
		self.fsm.set_animation("IDLE_OPEN")


func _physics_process(delta):
	if not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return
	var target = self.entity.get_target()
	var target_loc = (
		target.global_position
		+ (
			Vector2(cos(self._current_angle), sin(self._current_angle))
			* self.entity.ranged_attack_range
			* FOLLOW_DISTANCE_FAC
		)
	)

	var move = self.entity.get_steered_direction(target_loc)

	var dist = (target_loc - self.entity.global_position).length()
	# try to go to the location
	var wanted_vel = (
		move
		* self.entity.getv(LivingEntityVariable.MAX_SPEED)
		* MathUtils.interpolate(dist / 64, 0, 1, MathUtils.INTERPOLATE_OUT)
	)

	var multiplier = 1.0 if self._weapon_state == 0 else 0.1

	self._current_angle += ANGLE_INCREASE * delta * self._angle_mult * multiplier
	wanted_vel *= multiplier

	if not AI.has_LOS(self.entity.global_position, self.entity.global_position + move * 128):
		self._angle_mult *= -1
		self._current_angle = (self.entity.global_position - self.entity.get_target().global_position).angle()

	if not AI.has_LOS(self.entity.global_position, self.entity.get_target().global_position):
		self._los_counter += delta
		if self._los_counter >= MAX_LOS_WAIT:
			self.fsm.set_state(EnemyState.CHASING)
			self._angle_mult *= -1
	else:
		self._los_counter = 0

	_face_target()
	_handle_weapon(delta)

	_try_move(delta, wanted_vel)


func exit():
	self.entity.disable_pathfind -= 1
