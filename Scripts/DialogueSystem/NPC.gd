tool
class_name NPC

extends Node

const Dialogue = preload("res://Scripts/DialogueSystem/classes/Dialogue.gd")
const DialogueQueue = preload("res://Scripts/DialogueSystem/classes/DialogueQueue.gd")

export var id: String = ""
export var dialogue_file: Resource

var queue: DialogueQueue

func _ready():
	queue = DialogueQueue.new()
	if (!dialogue_file):
		print("No dialogue provided for NPC ", id)
	elif (Engine.editor_hint):
		print("NPC ", id, " loaded with ", len(dialogue_file.dialogues), " dialogues")
		
func init():
	if (!dialogue_file.dialogues.has("default")):
		print("No default dialogue found for NPC ", id)
		return
	queue.enqueue(dialogue_file.dialogues["default"])

func clear():
	queue.clear()
	init()

func init_with_data(queued_ids: Array):
	for d_id in queued_ids:
		if (dialogue_file.dialogues.has(d_id)):
			queue.enqueue(dialogue_file.dialogues[d_id])
			
func _get_id(d: Dialogue) -> String:
	return d.id

func save() -> Array:
	var ids = []
	for d in queue.get_contents():
		ids.append(d.id)
	return ids
	
func get_top_dialogue() -> Dialogue:
	return queue.dequeue()
	
func peek_top_dialogue() -> Dialogue:
	return queue.peek()
	
func unlock_dialogue(d_id: String) -> void:
	if (dialogue_file.dialogues.has(d_id)):
		queue.enqueue(dialogue_file.dialogues[d_id])

func remove_dialogue(d_id: String) -> void:
	queue.remove(d_id)
