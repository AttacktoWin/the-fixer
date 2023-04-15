# Author: Marcus

class_name PermanentSpeedUpgrade extends Upgrade

var _value = 0


func _init(value):
	self._value = value


func apply(entity, _type: int):
	var r1 = PermanentSpeedRunnable.new()
	r1.extra = self._value
	entity.variables.add_runnable(LivingEntityVariable.MAX_SPEED, r1)
	var r2 = PermanentSpeedRunnable.new()
	r2.extra = self._value
	entity.variables.add_runnable(LivingEntityVariable.ACCEL, r2)


func get_upgrade_types() -> Array:
	return [UpgradeType.ENTITY]


class PermanentSpeedRunnable:
	extends Runnable

	var extra = 0.0

	func run(arg):
		return arg * (1 + extra)
