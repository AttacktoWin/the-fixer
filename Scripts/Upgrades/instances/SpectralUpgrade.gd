# Author: Marcus

class_name SpectralUpgrade extends Upgrade


func apply(entity, _type: int):
	entity.is_spectral = true


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
