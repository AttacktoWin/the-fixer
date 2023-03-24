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


class SeekingBullet:
	extends Runnable

	var _offset = 0

	var default_angle = 0

	func tick(delta):
		var enemies = AI.get_all_enemies()
		if enemies.size() == 0:
			return
		var closest = enemies[0]
		var dist = (closest.global_position - self._parent.global_position).length()
		for x in range(1, enemies.size()):
			var t = (enemies[x].global_position - self._parent.global_position).length()
			if t < dist:
				closest = enemies[x]
				dist = t

		var angle_to = (closest.global_position - self._parent.global_position).angle()
		var current = self.default_angle + self._offset
		var off = MathUtils.angle_difference(angle_to, current)
		self._offset += off * delta * 4

	func run(_arg):
		return self.default_angle + self._offset


func _ready():
	self._cooldown = 0.001


func _fire(_direction: float, _target: Node2D = null):
	var bullet: BulletBase = BulletScene.instance().initialize(self._parent)
	Scene.runtime.add_child(bullet)
	bullet.global_position = Vector2(self.global_position.x, self.global_position.y)
	bullet.set_direction(_direction)
	# bullet.variables.add_runnable(
	# 	BulletBase.VARIABLE.DIRECTION, SinBullet.new().with_parent(bullet), 0
	# )
	# bullet.variables.add_runnable(
	# 	BulletBase.VARIABLE.DIRECTION, CurveBullet.new().with_parent(bullet), 0
	# )
	var runnable = SeekingBullet.new().with_parent(bullet)
	runnable.default_angle = _direction + rand_range(-1, 1)
	bullet.variables.add_runnable(AttackVariable.DIRECTION, runnable, 0)
	# add some screen shake!
	CameraSingleton.shake(3)
	AI.notify_sound(self.global_position)
