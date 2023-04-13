# Author: Marcus

class_name Level extends Node

export var is_ui: bool = false
export var ui_enabled: bool = true
export var vision_enabled: bool = true
export var vision_alpha: float = 1.0
export var vision_range: float = 0.3
export var enemy_appear_distance: float = 512
export var spawn_upgrades: bool = false
export var level_index: int = 0  # i hate this

const SAVE_UPGRADE_LIST = "UPGRADES"
const SAVE_MELEE = "MELEE"
const SAVE_RANGED = "RANGED"
const SAVE_PLAYER_DATA = "PLAYER_DATA"
const SAVE_SEED = "SEED"

var _temp_data = null

var _weapon_name_lookup = {
	PlayerGunPistol: "Pistol",
	PlayerGunShotgun: "Shotgun",
	PlayerGunTommy: "Tommy",
	PlayerMeleeBaton: "Baton",
	PlayerMeleeBrassKnuckles: "BrassKnuckles",
	PlayerMeleeKnife: "Knife",
}

var _weapon_scene_lookup = {
	"Pistol": preload("res://Scenes/Weapons/PlayerPistolScene.tscn"),
	"Shotgun": preload("res://Scenes/Weapons/PlayerShotgunScene.tscn"),
	"Tommy": preload("res://Scenes/Weapons/PlayerTommyGunScene.tscn"),
	"Baton": preload("res://Scenes/Weapons/PlayerBatonScene.tscn"),
	"BrassKnuckles": preload("res://Scenes/Weapons/PlayerBrassKnucklesScene.tscn"),
	"Knife": preload("res://Scenes/Weapons/PlayerKnifeScene.tscn"),
}


func _weapon_to_name(weapon):
	for key in self._weapon_name_lookup.keys():
		if weapon is key:
			return self._weapon_name_lookup[key]

	return ""


func _name_to_scene(name: String):
	for key in self._weapon_scene_lookup.keys():
		if key == name:
			return self._weapon_scene_lookup[key]

	return null


func load_data(data: Dictionary):
	self._temp_data = data

	var gen = get_node_or_null("Generator")
	if gen and gen.has_method("set_seed"):
		gen.set_seed(data[SAVE_SEED])

	Scene.connect("transition_complete", self, "update_player", [], CONNECT_ONESHOT)


func update_player():
	var upgrades = []
	for upgrade_name in self._temp_data[SAVE_UPGRADE_LIST]:
		upgrades.append(UpgradeSingleton.name_to_upgrade(upgrade_name).new())

	# StatsSingleton.apply_upgrades(Scene.player)
	Scene.player.apply_upgrades(upgrades)
	if self._temp_data[SAVE_RANGED] and not Scene.player.has_gun():
		Scene.player.set_gun(self._name_to_scene(self._temp_data[SAVE_RANGED]).instance())
	if self._temp_data[SAVE_MELEE] and not Scene.player.has_melee():
		Scene.player.set_melee(self._name_to_scene(self._temp_data[SAVE_MELEE]).instance())
	Scene.player.load_data(self._temp_data[SAVE_PLAYER_DATA])

	self._temp_data = null


func save() -> Dictionary:
	var data = {}
	var list = []
	for upgrade in Scene.player.upgrade_handler.get_all_known_upgrades():
		var up = UpgradeSingleton.name_from_upgrade(upgrade)
		if up:
			list.append(up)

	data[SAVE_UPGRADE_LIST] = list
	var gen = get_node_or_null("Generator")
	data[SAVE_SEED] = gen.get_seed() if gen and gen.has_method("get_seed") else 0
	data[SAVE_PLAYER_DATA] = Scene.player.save()
	data[SAVE_RANGED] = self._weapon_to_name(Scene.player._gun)
	data[SAVE_MELEE] = self._weapon_to_name(Scene.player._melee)

	return data
