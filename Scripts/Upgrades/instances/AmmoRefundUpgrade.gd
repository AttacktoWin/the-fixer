# Author: Marcus

class_name RefundChanceUpgrade extends Upgrade

const MAX_REFUND = 0.6


func apply(entity, _type: int):
	entity.refund_chance = (entity.refund_chance * 3 + MAX_REFUND) / 4.0


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
