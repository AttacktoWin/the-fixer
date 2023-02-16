class_name BaseHitHandler extends Object

var _attack = null

var camera_shake_on_hit = 8


func _init(attack):
	self._attack = attack


func on_hit(target: LivingEntity):
	var damage = self._attack.variables.get_variable(AttackVariable.DAMAGE)
	var dir = self._attack.variables.get_variable(AttackVariable.DIRECTION)

	var meta = HitMetadata.new(Vector2(cos(dir), sin(dir)).normalized())
	if target.try_take_damage(damage, meta):
		CameraSingleton.shake(self.camera_shake_on_hit)
