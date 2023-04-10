# Author: Marcus

class_name PlayerGunPistol extends PlayerBaseGun


func _fire(direction: float, _target: Node2D = null):
	for j in range(calc_multishot()):
		var bullet: BulletBase = self._generate_bullet()
		if j > 0 and bullet_spread == 0:
			bullet.set_direction(direction + rand_range(-0.15, 0.15))
		else:
			bullet.set_direction(direction + rand_range(-bullet_spread, bullet_spread))
		CameraSingleton.shake(self.screen_shake_on_fire)
