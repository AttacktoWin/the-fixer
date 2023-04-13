extends Node2D

func _ready():
	$Area2D.connect("body_entered",self,"start_dialogue")

func start_dialogue(body):
	if body is Player:
		$FixerNPCInstance.interact()
