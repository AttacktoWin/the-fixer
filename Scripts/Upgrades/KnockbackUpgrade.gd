# Author: Marcus

class_name KnockbackUpgrade extends Upgrade

const KNOCKBACK_ADD = 0.25


func apply(entity, type: int):
	if type == UpgradeType.WEAPON:
		entity.knockback_multiplier += KNOCKBACK_ADD
	if type == UpgradeType.ATTACK:
		entity.variables.add_runnable(AttackVariable.KNOCKBACK, KnockbackRunnable.new())


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON, UpgradeType.ATTACK]


class KnockbackRunnable:
	extends Runnable

	func run(arg):
		return arg * (1 + KNOCKBACK_ADD)
