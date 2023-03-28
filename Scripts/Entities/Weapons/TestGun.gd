class_name TestGun extends BaseGun

var BulletScene = preload("res://Scenes/Weapons/bullet_scene.tscn")


class SinBullet:
	extends Runnable

	var _timer = 0

	func _physics_process(delta):
		self._timer += delta * 120

	func run(_arg):
		return _arg + sin(self._timer / 2)


class CurveBullet:
	extends Runnable

	var _timer = 0

	func _physics_process(delta):
		self._timer += delta * 3

	func run(_arg):
		return _arg + self._timer


class SeekingBullet:
	extends Runnable

	var _offset = 0

	func _on_added():
		self.default_value += rand_range(-1, 1)

	func _physics_process(delta):
		var enemies = AI.get_all_enemies()
		if enemies.size() == 0:
			return
		var closest = enemies[0]
		var dist = (closest.global_position - self.entity.global_position).length()
		for x in range(1, enemies.size()):
			var t = (enemies[x].global_position - self.entity.global_position).length()
			if t < dist:
				closest = enemies[x]
				dist = t

		var angle_to = (closest.global_position - self.entity.global_position).angle()
		var current = self.default_value + self._offset
		var off = MathUtils.angle_difference(angle_to, current)
		self._offset += off * delta * 4

	func run(_arg):
		return self.default_value + self._offset


func _init(parent_entity).(parent_entity):
	pass


# func _ready():
# 	self._cooldown = 0.01


func _fire(direction: float, _target: Node2D = null):
	var bullet: BulletBase = BulletScene.instance().set_damage_source(self.entity)
	Scene.runtime.add_child(bullet)
	bullet.set_direction(direction)
	bullet.global_position = self.global_position

	# bullet.variables.add_runnable(
	# 	BulletBase.VARIABLE.DIRECTION, SinBullet.new().with_parent(bullet), 0
	# )
	# bullet.variables.add_runnable(
	# 	BulletBase.VARIABLE.DIRECTION, CurveBullet.new().with_parent(bullet), 0
	# )
	# var runnable = SeekingBullet.new()
	# bullet.variables.add_runnable(AttackVariable.DIRECTION, runnable, 0)
	# add some screen shake!
	CameraSingleton.shake(3)
	AI.notify_sound(self.global_position)
