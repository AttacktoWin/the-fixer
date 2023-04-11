# Author: Marcus

class_name MaxAmmoUpgrade extends Upgrade


func apply(entity, _type: int):
	entity.max_ammo += 1


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
