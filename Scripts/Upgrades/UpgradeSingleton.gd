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
const UPGRADE_TEX_IDX = 3
const UPGRADE_DESCRIPTION = 4

var _class_lookup = {
	"AmmoRefund": [RefundChanceUpgrade, COMMON, FLAG_NONE, 3, "+ Ammo Refund Chance"],
	"AttackSpeed": [AttackSpeedUpgrade, COMMON, FLAG_NONE, 0, "+ Attack Speed"],
	"Damage": [DamageUpgrade, COMMON, FLAG_NONE, 1, "+ Damage"],
	"Healing": [HealingUpgrade, PLENTIFUL, FLAG_NONE, 2, "+ Bandage Healing"],
	"Homing": [HomingUpgrade, VERY_RARE, FLAG_SINGLE, 4, "Homing"],
	"Knockback": [KnockbackUpgrade, COMMON, FLAG_NONE, 5, "+ Knockback"],
	"MaxAmmo": [MaxAmmoUpgrade, PLENTIFUL, FLAG_NONE, 6, "+ Max Ammo"],
	"MaxHealth": [MaxHealthUpgrade, PLENTIFUL, FLAG_NONE, 8, "+ Max Health"],
	"MultishotChance": [MultishotUpgrade, UNCOMMON, FLAG_NONE, 9, "+ Multishot Chance"],
	"PierceChance": [PierceChanceUpgrade, UNCOMMON, FLAG_NONE, 10, "+ Pierce Chance"],
	"Spectral": [SpectralUpgrade, VERY_RARE, FLAG_SINGLE, 7, "Spectral Bullets"],
	"Speed": [SpeedUpgrade, COMMON, FLAG_NONE, 11, "+ Speed"],
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


func get_upgrade_tex_frame(name: String) -> int:
	return self._class_lookup[name][UPGRADE_TEX_IDX]


func pick_random_upgrade():
	var rng = randf()
	for x in self._chances:
		if rng <= x[1]:
			return x[0]


func pick_random_upgrade_checked():
	while true:
		var up_name = pick_random_upgrade()
		var valid = true
		if self._class_lookup[up_name][UPGRADE_FLAG] == FLAG_SINGLE:
			for handler in Scene.player.get_all_upgrade_handlers():
				if handler.has_upgrade(up_name):
					valid = false
					break

		if valid:
			return up_name


func pick_upgrade_pair():
	var upgrade1 = pick_random_upgrade_checked()
	var upgrade2 = pick_random_upgrade_checked()
	while upgrade1 == upgrade2:
		upgrade2 = pick_random_upgrade_checked()

	return [upgrade1, upgrade2]


func name_from_upgrade(upgrade: Upgrade, use_class = false) -> String:
	for key in self._class_lookup.keys():
		var data = self._class_lookup[key]
		if use_class:
			if upgrade.get_script() == data[UPGRADE_CLASS].get_script():
				return key
		else:
			if upgrade is data[UPGRADE_CLASS]:
				return key
	return ""
