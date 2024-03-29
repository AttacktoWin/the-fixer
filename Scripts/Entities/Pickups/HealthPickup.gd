# Author: Marcus

class_name HealthPickup extends WorldPickup

const DEFAULT_HEALING = 25

export var amount: int = DEFAULT_HEALING


func _init(healing: int = DEFAULT_HEALING):
	self._texture = preload("res://Assets/Items/bandaid.png")
	if amount == DEFAULT_HEALING:
		self.amount = healing
	self.pickup_distance = 128
	self.pickup_height = 128


func collection_check(collector: LivingEntity):
	var health = collector.getv(LivingEntityVariable.HEALTH)
	return health < collector.getv(LivingEntityVariable.MAX_HEALTH)


func on_collected(collector: LivingEntity):
	collector.add_health(self.amount)
