# Author: Marcus

class_name MultishotUpgrade extends Upgrade

const MULTISHOT_ADD = 0.2


func apply(entity, _type: int):
	entity.multishot_chance += MULTISHOT_ADD


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
