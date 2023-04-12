# Author: Marcus

class_name AttackSizeUpgrade extends Upgrade

const SIZE_ADD = 1


func apply(entity, type: int):
	if type == UpgradeType.WEAPON:
		entity.size_multiplier += SIZE_ADD
	if type == UpgradeType.ATTACK:
		if entity.get_node_or_null("HitCollider"):
			entity.get_node_or_null("HitCollider").scale *= (1 + SIZE_ADD)
		else:
			entity.scale *= (1 + SIZE_ADD)


func get_upgrade_types() -> Array:
	return [UpgradeType.WEAPON, UpgradeType.ATTACK]
