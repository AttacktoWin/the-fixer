# Author: Marcus

class_name PermanentMeleeDamageUpgrade extends Upgrade

var _value = 0


func _init(value):
	self._value = value


func apply(entity, _type: int):
	var r = PermanentMeleeDamageRunnable.new()
	r.extra = self._value
	entity.variables.add_runnable(AttackVariable.DAMAGE, r)


func get_upgrade_types() -> Array:
	return [UpgradeType.ATTACK]


class PermanentMeleeDamageRunnable:
	extends Runnable

	var extra = 0.0

	func run(arg):
		return arg * (1 + extra)
