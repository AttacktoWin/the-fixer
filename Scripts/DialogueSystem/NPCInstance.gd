class_name NPCInstance
extends Node2D

export var id: String
export var immediate: bool
export var randomized: bool

var interacted: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	interacted = false
	if self.id == "boss" \
	&& DialogueSystem.peek_top_dialogue("boss").priority == Dialogue.Priority.SPECIFIC:
		interacted = true
		_update_player_position()
		var tween = Tween.new()
		add_child(tween)
		tween.interpolate_callback(self, 0.5, "_interact_proxy")
		tween.start()
	if randomized:
		if randi()%100 <= 30:
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
	
func _update_player_position():
	if (is_instance_valid(Scene.player)):
		(Scene.player as Player).position = Vector2(-717, -460)

func _interact_proxy():
	self.interacted = false
	interact()
