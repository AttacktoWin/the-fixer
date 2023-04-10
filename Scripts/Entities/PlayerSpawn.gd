extends Node2D

func _ready():
	if Scene.player:
		Scene.player.global_position = self.global_position
