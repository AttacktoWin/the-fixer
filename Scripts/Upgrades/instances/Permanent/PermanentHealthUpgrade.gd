# Author: Marcus

class_name PermanentHealthUpgrade extends Upgrade

var _value = 0


func _init(value):
	self._value = value


func apply(entity, _type: int):
	var r = PermanentHealthRunnable.new()
	r.extra = self._value
	entity.variables.add_runnable(LivingEntityVariable.MAX_HEALTH, r)
	entity.update_health_bar()


func get_upgrade_types() -> Array:
	return [UpgradeType.ENTITY]


class PermanentHealthRunnable:
	extends Runnable

	var extra = 0.0

	func run(arg):
		return arg + self.extra
