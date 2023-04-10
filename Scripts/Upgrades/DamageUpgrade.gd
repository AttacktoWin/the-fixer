# Author: Marcus

class_name DamageUpgrade extends Upgrade

const DAMAGE_MULTIPLIER = 0.2


func apply(entity, type: int):
	if type == UpgradeType.WEAPON:
		entity.damage_multiplier += DAMAGE_MULTIPLIER
	if type == UpgradeType.ATTACK:
		entity.variables.add_runnable(AttackVariable.DAMAGE, DamageRunnable.new())


func get_upgrade_types() -> Array:
	return [UpgradeType.ATTACK, UpgradeType.WEAPON]


class DamageRunnable:
	extends Runnable

	func run(arg):
		return arg * (1 + DAMAGE_MULTIPLIER)
