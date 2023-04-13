# Author: Marcus

class_name AttackSpeedUpgrade extends Upgrade

const SPEED_MULT = 1.15


func apply(entity, type: int):
	if type == UpgradeType.WEAPON:
		entity.cooldown /= SPEED_MULT
	if type == UpgradeType.MELEE:
		entity.attack_speed *= SPEED_MULT


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON, UpgradeType.MELEE]
