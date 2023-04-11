# Author: Marcus

class_name RefundChanceUpgrade extends Upgrade

const MAX_REFUND = 0.5


func apply(entity, _type: int):
	entity.refund_chance = (entity.refund_chance * 5 + MAX_REFUND) / 6.0


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON]
