# Author: Marcus

class_name Level extends Node

export var is_ui: bool = false
export var ui_enabled: bool = true
export var vision_enabled: bool = true
export var vision_alpha: float = 1.0
export var vision_range: float = 0.3
export var enemy_appear_distance: float = 512
export var spawn_upgrades: bool = false


func _ready():
	Scene.connect("world_updated", self, "_world_updated", [], CONNECT_ONESHOT)


func _world_updated():
	if self.spawn_upgrades:
		var upgrades = DualUpgrade.new()
		Scene.runtime.add_child(upgrades)
		upgrades.global_position = Scene.player.global_position
