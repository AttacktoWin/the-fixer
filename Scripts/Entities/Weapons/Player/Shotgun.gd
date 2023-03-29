# Author: Marcus

class_name PlayerGunShotgun extends PlayerBaseGun

export var bullets: int = 5
export var user_knockback: float = 64
export var random_speed: int = 50


func _fire(direction: float, _target: Node2D = null):
	for _i in range(bullets):
		var bullet: BulletBase = self._generate_bullet()
		bullet.changev(AttackVariable.SPEED, rand_range(-random_speed, random_speed))
		bullet.set_direction(direction + rand_range(-bullet_spread, bullet_spread))

	self.entity.knockback(Vector2(cos(direction), sin(direction)) * -user_knockback)

	CameraSingleton.shake(self.screen_shake_on_fire)
	AI.notify_sound(self.global_position)
