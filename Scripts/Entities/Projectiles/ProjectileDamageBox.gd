# this class is expected to be in the hitbox and be named "hurt_info"
class_name DamageBox extends Object

var _damage_owner = null

var hurt_info setget , _hurt_info_get


func _hurt_info_get():
	return HurtInfo.new(
		self._damage_owner.variables.get_variable(BulletBase.VARIABLE.DAMAGE),
		self._damage_owner.variables.get_variable(BulletBase.VARIABLE.DIRECTION)
	)


func _init(damage_owner = null):
	self._damage_owner = damage_owner


func with_damage_owner(damage_owner):
	self._damage_owner = damage_owner
	return self


# warning-ignore:unused_argument
func can_hurt(entity: LivingEntity):
	return true
