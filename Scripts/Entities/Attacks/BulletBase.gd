class_name BulletBase extends BaseAttack


func _process(delta):
	._process(delta)
	if self.variables.get_variable(AttackVariable.LIFE) < 0:
		self._expire()


func _physics_process(_delta):
	._physics_process(_delta)
	events.invoke(EVENTS.MOVE, null)
	var dir = self.variables.get_variable(AttackVariable.DIRECTION)
	var speed = self.variables.get_variable(AttackVariable.SPEED)
	self.rotation = dir
	var vel = Vector2(cos(dir), sin(dir)) * speed * _delta
	self.position += vel
