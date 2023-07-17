# Author: Marcus

# exclusively used by the player

class_name PlayerBaseGun extends Weapon

export(AK.EVENTS._dict) var sound_fire: int = -1
export(AK.EVENTS._dict) var sound_empty: int = -1
export(int) var ammo_damage_override: int = -1
export(int) var ammo_speed_override: int = -1
export(int) var ammo_knockback_override: int = -1
export(int) var screen_shake_on_fire: int = 3
export var bullet_spread: float = 0
export var weapon_volume: float = 2.5

var _flash_sprite = null


func _notify_fire(has_ammo):
	self.entity.update_ammo_counter()
	if has_ammo:
		if self._flash_sprite:
			self._flash_sprite.play_flash()
		AI.notify_sound(self.entity.global_position, 4096, weapon_volume)
		if self.sound_fire:
			Wwise.post_event_id(self.sound_fire, self.entity)
	else:
		if self.sound_empty:
			Wwise.post_event_id(self.sound_empty, self.entity)


func _apply_base_stats(attack: BaseAttack):
	if not attack.is_inside_tree():
		print(
			"WARN: Attempting to modify attack before it has entered the scene. Some changes will be lost!"
		)
	if self.ammo_damage_override != -1:
		attack.setv(AttackVariable.DAMAGE, self.ammo_damage_override)
	if self.ammo_speed_override != -1:
		attack.setv(AttackVariable.SPEED, self.ammo_speed_override)
	if self.ammo_knockback_override:
		attack.setv(AttackVariable.KNOCKBACK, ammo_knockback_override)

	attack.setv(
		AttackVariable.DAMAGE, ceil(attack.getv(AttackVariable.DAMAGE) * self.damage_multiplier)
	)
	attack.scale *= self.size_multiplier
	attack.setv(
		AttackVariable.KNOCKBACK,
		attack.variables.get_variable_raw(AttackVariable.KNOCKBACK) * self.knockback_multiplier
	)

	attack.spectral = attack.spectral or self.is_spectral

	if self.is_homing:
		attack.variables.add_runnable(AttackVariable.DIRECTION, HomingBullet.new())

	var t = self.pierce_chance
	while t > 0:
		if randf() < t:
			attack.max_pierce += 1
		t -= 1

	return attack


func _generate_bullet() -> BulletBase:
	var bullet: BulletBase = ammo_scene.instance().set_damage_source(self.entity)
	Scene.runtime.add_child(bullet)
	bullet.global_position = self.global_position
	return self._apply_base_stats(bullet)


func _get_fire_angle():
	if self.entity.is_controller():
		return self.entity.controller_wanted_gun_vector().angle()
	var angle1 = MathUtils.to_iso(CameraSingleton.get_absolute_mouse() - self.global_position).angle()
	var angle2 = MathUtils.to_iso(CameraSingleton.get_absolute_mouse() - self._get_aim_position()).angle()
	return angle1 if abs(angle1 - angle2) < 0.1 else angle2


func set_muzzle_flash_sprite(spr: AnimatedSprite):
	self._flash_sprite = spr


# override
func _on_fire_called():
	self._try_fire(self._get_fire_angle(), null)  # warning-ignore:return_value_discarded


func _check_fire_just_pressed():
	return (
		not PausingSingleton.is_paused_recently()
		and Input.is_action_just_pressed("weapon_fire_ranged")
	)


func _check_fire_pressed():
	return (
		not PausingSingleton.is_paused_recently()
		and Input.is_action_pressed("weapon_fire_ranged")
	)
