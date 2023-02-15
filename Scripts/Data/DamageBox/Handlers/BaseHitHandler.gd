class_name BaseHitHandler extends Object

var _attack = null

var camera_shake_on_hit = 100


func _init(attack):
	self._attack = attack


func on_hit(target: LivingEntity):
	var damage = self._attack.variables.get_variable(AttackVariable.DAMAGE)
	if target.try_take_damage(damage):
		CameraSingleton.shake(self.camera_shake_on_hit)
