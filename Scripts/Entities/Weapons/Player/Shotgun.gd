# Author: Marcus

class_name PlayerGunShotgun extends PlayerBaseGun

export var bullets: int = 5
export var user_knockback: float = 64
export var random_speed: int = 50


func _fire(direction: float, _target: Node2D = null):
	var _bullets = []
	for _i in range(bullets):
		var bullet: BulletBase = ammo_scene.instance().set_damage_source(self.entity)
		for b in _bullets:
			bullet.add_connected_bullet(b)
		_bullets.append(bullet)

	for bullet in _bullets:
		Scene.runtime.add_child(bullet)
		bullet.changev(AttackVariable.SPEED, rand_range(-random_speed, random_speed))
		bullet.set_direction(direction + rand_range(-bullet_spread, bullet_spread))
		bullet.global_position = self.global_position
		_apply_base_stats(bullet)

	self.entity.knockback(Vector2(cos(direction), sin(direction)) * -user_knockback)

	CameraSingleton.shake(self.screen_shake_on_fire)
