# Author: Marcus

class_name PermanentRangedDamageUpgrade extends Upgrade

var _value = 0


func _init(value):
	self._value = value


func apply(entity, _type: int):
	entity.damage_multiplier += self._value


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
