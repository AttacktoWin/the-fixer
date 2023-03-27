class_name BulletBase extends BaseAttack


func _physics_process(_delta):
	._physics_process(_delta)
	events.invoke(EVENTS.MOVE, null)
	var dir = self.variables.get_variable(AttackVariable.DIRECTION)
	var speed = self.variables.get_variable(AttackVariable.SPEED)
	self.position += Vector2(cos(dir), sin(dir)) * speed * _delta
