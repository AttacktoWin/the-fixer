# Author: Marcus

class_name MaxHealthUpgrade extends Upgrade

const HEALTH_INCREASE = 20


func apply(entity, _type: int):
	entity.variables.add_runnable(LivingEntityVariable.MAX_HEALTH, HealthRunnable.new())
	entity.update_health_bar()


class HealthRunnable:
	extends Runnable

	func run(arg):
		return arg + 20
