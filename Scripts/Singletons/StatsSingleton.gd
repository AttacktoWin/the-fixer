extends Node

var available_tokens = 0

const MAX = 10
var stats = [0, 0, 0, 0]


func increment(index):
	if stats[index] + 1 <= MAX and available_tokens > 0:
		stats[index] += 1
		available_tokens -= 1


func reset():
	var total = available_tokens
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
			PermanentHealthUpgrade.new(self.stats[0] * 10),
			PermanentSpeedUpgrade.new(self.stats[1] * 0.05),
			PermanentMeleeDamageUpgrade.new(self.stats[2] * 0.03),
			PermanentRangedDamageUpgrade.new(self.stats[3] * 0.03),
		]
	)


func load_data(data):
	self.available_tokens = data[0]
	self.stats[0] = data[1]
	self.stats[1] = data[2]
	self.stats[2] = data[3]
	self.stats[3] = data[4]


func save():
	return [
		self.available_tokens,
		self.stats[0],
		self.stats[1],
		self.stats[2],
		self.stats[3],
	]
