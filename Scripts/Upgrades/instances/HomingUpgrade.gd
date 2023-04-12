# Author: Marcus

class_name HomingUpgrade extends Upgrade


func apply(entity, _type: int):
	entity.is_homing = true


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
