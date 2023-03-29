# Author: Marcus

class_name PlayerGunPistol extends PlayerBaseGun


func _fire(direction: float, _target: Node2D = null):
	var bullet: BulletBase = self._generate_bullet()
	bullet.set_direction(direction + rand_range(-bullet_spread, bullet_spread))
	CameraSingleton.shake(self.screen_shake_on_fire)
	AI.notify_sound(self.global_position)
