extends Node

var available_tokens = 13

var health_upgrades: int = 0
var speed_upgrades: int = 0
var melee_damage_upgrades: int = 0
var ranged_damage_upgrades: int = 0


const MAX = 12
var stats = [
	self.health_upgrades,
	self.speed_upgrades,
	self.melee_damage_upgrades,
	self.ranged_damage_upgrades]

func increment(index):
	if stats[index]+1<= MAX and available_tokens>0:
		stats[index]+=1
		available_tokens-=1

func reset():
	var total = 0
	for stat in stats.size():
		total+=stats[stat]
		stats[stat] = 0
	available_tokens = total
