# Author: Marcus

class_name KnockbackUpgrade extends Upgrade

const KNOCKBACK_ADD = 0.25


func apply(entity, type: int):
	if type == UpgradeType.WEAPON:
		entity.knockback_multiplier += KNOCKBACK_ADD
	if type == UpgradeType.ATTACK:
		entity.knockback_factor *= (1 + KNOCKBACK_ADD)


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON, UpgradeType.ATTACK]
