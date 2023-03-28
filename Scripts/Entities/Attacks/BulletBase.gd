class_name BulletBase extends BaseAttack


func _on_hit_entity(_entity: LivingEntity):
	pass
	#Wwise.post_event_id(AK.EVENTS.HIT_PISTOL_PLAYER, self._damage_source)


func _physics_process(_delta):
	._physics_process(_delta)
	events.invoke(EVENTS.MOVE, null)
	var dir = self.variables.get_variable(AttackVariable.DIRECTION)
	var speed = self.variables.get_variable(AttackVariable.SPEED)
	self.position += Vector2(cos(dir), sin(dir)) * speed * _delta
