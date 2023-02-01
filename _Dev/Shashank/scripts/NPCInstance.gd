class_name NPCInstance
extends Node2D

export var id: String
var interacted: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	interacted = false
	# Just for testing
	interact()

# TODO: make this a common function for all interactibles
func interact() -> void:
	if (interacted):
		return
	var system = get_node("/root/DialogueSystem")
	if (is_instance_valid(system)):
		var dialogue = system.get_top_dialogue(id)
		if (is_instance_valid(dialogue)):
			print(dialogue)
			system.display_dialogue(id, dialogue.id)
		else:
			print("something wrong with dialogue")
	else:
		print("Something wrong with system")
	interacted = true
