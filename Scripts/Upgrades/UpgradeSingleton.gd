# Author: Marcus
extends Node

const PLENTIFUL = 15
const COMMON = 10
const UNCOMMON = 5
const RARE = 2.5
const VERY_RARE = 1.5

const INACCESSIBLE = 0

const FLAG_NONE = 0
const FLAG_SINGLE = 1

const UPGRADE_CLASS = 0
const UPGRADE_CHANCE = 1
const UPGRADE_FLAG = 2
const UPGRADE_DESCRIPTION = 3

var _class_lookup = {
	"AmmoRefund": [RefundChanceUpgrade, COMMON, FLAG_NONE, "+ Refund Chance"],
	#"AttackSize": [AttackSizeUpgrade, COMMON, FLAG_NONE, "+ Attack Size"],
	"Damage": [DamageUpgrade, COMMON, FLAG_NONE, "+ Damage"],
	"Healing": [HealingUpgrade, PLENTIFUL, FLAG_NONE, "+ Bandage Healing"],
	"Homing": [HomingUpgrade, VERY_RARE, FLAG_SINGLE, "Homing"],
	"Knockback": [KnockbackUpgrade, COMMON, FLAG_NONE, "+ Knockback"],
	"MaxAmmo": [MaxAmmoUpgrade, PLENTIFUL, FLAG_NONE, "+ Max Ammo"],
	"MaxHealth": [MaxHealthUpgrade, PLENTIFUL, FLAG_NONE, "+ Max Health"],
	"MultishotChance": [MultishotUpgrade, UNCOMMON, FLAG_NONE, "+ Multishot Chance"],
	"PierceChance": [PierceChanceUpgrade, UNCOMMON, FLAG_NONE, "+ Pierce Chance"],
	"Spectral": [SpectralUpgrade, VERY_RARE, FLAG_SINGLE, "Spectral Bullets"],
	"Speed": [SpeedUpgrade, COMMON, FLAG_NONE, "+ Speed"],
}

var _chances = []  # [norm_chance, class_name]


func _ready():
	var sum: float = 0
	for key in self._class_lookup.keys():
		sum += self._class_lookup[key][UPGRADE_CHANCE]

	var current: float = 0
	for key in self._class_lookup.keys():
		var data = self._class_lookup[key]
		if data[UPGRADE_CHANCE] == INACCESSIBLE:
			continue
		current += data[UPGRADE_CHANCE] / sum * 1.0
		self._chances.append([key, current])
	self._chances[-1][1] = 1.0  # ensure last is 100% chance


func name_to_upgrade(name: String) -> GDScript:
	return self._class_lookup[name][UPGRADE_CLASS]


func get_upgrade_description(name: String) -> String:
	return self._class_lookup[name][UPGRADE_DESCRIPTION]


func pick_random_upgrade():
	var rng = randf()
	for x in self._chances:
		if rng <= x[1]:
			return x[0]


func pick_upgrade_pair():
	var upgrade1 = pick_random_upgrade()
	var upgrade2 = pick_random_upgrade()
	while upgrade1 == upgrade2:
		upgrade2 = pick_random_upgrade()

	return [upgrade1, upgrade2]
