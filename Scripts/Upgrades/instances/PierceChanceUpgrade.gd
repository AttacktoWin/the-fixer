# Author: Marcus

class_name PierceChanceUpgrade extends Upgrade

const PIERCE_ADD = 0.2


func apply(entity, _type: int):
	entity.pierce_chance += PIERCE_ADD


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
