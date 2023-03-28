class_name NPCInstance
extends Node2D

export var id: String
export var immediate: bool
export var randomized: bool

var interacted: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	interacted = false
	if randomized:
		if randi()%100<=30:
			call_deferred("interact")
	elif immediate:
		call_deferred("interact")

# TODO: make this a common function for all interactibles
func interact() -> void:
	if (interacted):
		return
	var dialogue = DialogueSystem.get_top_dialogue(id)
	if (is_instance_valid(dialogue)):
		DialogueSystem.display_dialogue(id, dialogue.id, dialogue.bubble)
	else:
		print("Something wrong with dialogue")
	interacted = true
