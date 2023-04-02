# Author: Marcus

extends Area2D

export(PackedScene) var to_level
var cleared:bool = false

func _ready() -> void:
	#warning-ignore:RETURN_VALUE_DISCARDED
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exit")

func _process(_delta):
	if AI.get_all_enemies().size() == 0:
		cleared = true
		$Exit.frame = 1

func _on_body_entered(body: Node2D):
	if body is Player and cleared:
		self.call_deferred("_transition")
	elif body is Player:
		$ExitMessage.visible = true

func _on_body_exit(body:Node2D):
	if body is Player:
		$ExitMessage.visible = false


func _transition():
	var inst = to_level.instance()
	Scene.switch(inst)
