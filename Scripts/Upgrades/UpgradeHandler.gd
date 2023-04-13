# Author: Marcus

class_name UpgradeHandler extends Resource

var _known_upgrades = []
var _entity = null
var _filter_type = null
var _primary = false
var _all_known_upgrades = []


func _init(enity, filter_type, primary = false):
	self._entity = enity
	assert(filter_type != null, "Filter must be supplied!")
	self._filter_type = filter_type
	self._primary = primary


func get_all_known_upgrades() -> Array:
	assert(self._primary, "Cannot get all upgrades on non primary upgrade handler")
	return self._all_known_upgrades


func clear_upgrades() -> void:
	self._known_upgrades = []



func add_upgrades(upgrades: Array):
	for upgrade in upgrades:
		if self._primary and not upgrade in self._all_known_upgrades:
			self._all_known_upgrades.append(upgrade)
		if upgrade in self._known_upgrades:
			continue

		if self._filter_type in upgrade.get_upgrade_types():
			self._known_upgrades.append(upgrade)
			upgrade.apply(self._entity, self._filter_type)
