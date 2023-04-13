extends Node

var available_tokens = 0

var health_upgrades: int = 0
var speed_upgrades: int = 0
var melee_damage_upgrades: int = 0
var ranged_damage_upgrades: int = 0

const MAX = 12
var stats = [
	self.health_upgrades,
	self.speed_upgrades,
	self.melee_damage_upgrades,
	self.ranged_damage_upgrades
]


func increment(index):
	if stats[index] + 1 <= MAX and available_tokens > 0:
		stats[index] += 1
		available_tokens -= 1


func reset():
	var total = 0
	for stat in stats.size():
		total += stats[stat]
		stats[stat] = 0
	available_tokens = total


func apply_upgrades(entity):
	if entity.upgrades_applied:
		return
	entity.upgrades_applied = true
	entity.apply_upgrades(
		[
			PermanentHealthUpgrade.new(self.health_upgrades * 10),
			PermanentSpeedUpgrade.new(self.speed_upgrades * 0.05),
			PermanentMeleeDamageUpgrade.new(self.melee_damage_upgrades * 0.03),
			PermanentRangedDamageUpgrade.new(self.ranged_damage_upgrades * 0.03),
		]
	)


func load_data(data):
	self.available_tokens = data[0]
	self.health_upgrades = data[1]
	self.speed_upgrades = data[2]
	self.melee_damage_upgrades = data[3]
	self.ranged_damage_upgrades = data[4]


func save():
	return [
		self.available_tokens,
		self.health_upgrades,
		self.speed_upgrades,
		self.melee_damage_upgrades,
		self.ranged_damage_upgrades
	]
