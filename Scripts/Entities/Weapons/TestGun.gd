class_name TestGun extends BaseGun

var BulletScene = preload("res://Scenes/Weapons/bullet_scene.tscn")


class SinBullet:
	extends Runnable

	var _timer = 0

	func tick(delta):
		self._timer += delta * 120

	func run(_arg):
		return _arg + sin(self._timer / 2)


class CurveBullet:
	extends Runnable

	var _timer = 0

	func tick(delta):
		self._timer += delta * 3

	func run(_arg):
		return _arg + self._timer


func _fire(_direction, _target = null):
	var bullet: BulletBase = BulletScene.instance()
	bullet.position = Vector2(self.global_position.x, self.global_position.y)
	bullet.set_direction(_direction)
	# bullet.variables.add_runnable(
	# 	BulletBase.VARIABLE.DIRECTION, SinBullet.new().with_parent(bullet), 0
	# )
	# bullet.variables.add_runnable(
	# 	BulletBase.VARIABLE.DIRECTION, CurveBullet.new().with_parent(bullet), 0
	# )

	get_tree().get_root().add_child(bullet)
	# add some screen shake!
	CameraSingleton.shake(3)
