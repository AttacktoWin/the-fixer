# Author: Marcus

class_name MaxAmmoUpgrade extends Upgrade


func apply(entity, _type: int):
	entity.max_ammo += 1
	if entity.has_method("update_ammo_counter"):
		entity.update_ammo_counter()


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
