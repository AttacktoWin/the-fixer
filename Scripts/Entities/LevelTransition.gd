# Author: Marcus

extends Area2D

export(PackedScene) var to_level


func _ready() -> void:
	#warning-ignore:RETURN_VALUE_DISCARDED
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body: Node2D):
	if body is Player:
		var inst = to_level.instance()
		Scene.switch(inst)
