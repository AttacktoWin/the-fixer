# Author: Marcus

class_name SpeedUpgrade extends Upgrade

const SPEED_INCREASE = 1.2


func apply(entity, _type: int):
	entity.variables.add_runnable(LivingEntityVariable.MAX_SPEED, SpeedRunnable.new())
	entity.variables.add_runnable(LivingEntityVariable.ACCEL, SpeedRunnable.new())


class SpeedRunnable:
	extends Runnable

	func run(arg):
		return arg * SPEED_INCREASE
