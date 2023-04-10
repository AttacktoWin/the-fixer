# Author: Marcus

class_name HealingUpgrade extends Upgrade

const HEALING_INCREASE = 0.2


func apply(entity, _type: int):
	entity.healing_multiplier += HEALING_INCREASE
