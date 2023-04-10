class_name HomingBullet extends Runnable

var _offset = 0
var _first_frame = true


func _physics_process(delta):
	if self._first_frame:
		self.default_value = (
			self.entity.variables.get_variable_raw(AttackVariable.DIRECTION)
			+ rand_range(-0.6, 0.6)
		)
		self._first_frame = false

	var enemies = AI.get_all_enemies()
	if enemies.size() == 0:
		return
	var closest = null
	var dist = 999999
	for x in range(enemies.size()):
		if enemies[x].is_dead():
			continue
		var t = (enemies[x].global_position - self.entity.global_position).length()
		if t < dist:
			closest = enemies[x]
			dist = t

	if not closest:
		return

	var angle_to = (closest.global_position - self.entity.global_position).angle()
	var current = self.default_value + self._offset
	var off = MathUtils.angle_difference(angle_to, current)
	self._offset += off * delta * 6


func run(_arg):
	return self.default_value + self._offset
