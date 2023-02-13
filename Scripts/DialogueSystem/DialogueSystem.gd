tool
extends Node


const NPC = preload("res://Scripts/DialogueSystem/NPC.gd")
const DialogueNPCIds = preload("res://Scripts/DialogueSystem/classes/DialogueNpcIds.gd")
const Dialogue = preload("res://Scripts/DialogueSystem/classes/Dialogue.gd")

export var dialogue_unlock_table: Resource
export var save_file_name: String = ""

var NPCs: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	var init_time: int
	if (Engine.editor_hint):
		print("Loading Dialogue System")
		init_time = Time.get_ticks_usec()
	for child in get_children():
		if (child is NPC):
			NPCs[child.id] = child
			
	var save_dict: Dictionary = {}
	var dir = Directory.new()
	if (dir.file_exists(save_file_name)):
		dir.free()
		var file = File.new()
		file.open(save_file_name, File.READ)
		var text = file.get_as_text()
		file.close()
		file.free()
		var json = JSON.parse(text)
		if (json.error == OK):
			if (typeof(json.result) == TYPE_DICTIONARY):
				save_dict = json.result as Dictionary
			else:
				print("Malformed save data.")
		else:
			print("JSON Parse Error: ", json.error, " in ", text, " at line ", json.error_line)
	for npc in NPCs.values():
		if (save_dict.has(npc.id)):
			npc.init_with_data(save_dict[npc.id] as Array)
		else:
			npc.init()
			
	if (Engine.editor_hint):
		print("Loaded Dialogue System in {time} usec.".format({"time": Time.get_ticks_usec() - init_time}))
		
		
func display_dialogue(npc_id: String, dialogue_id: String) -> void:
	# TODO: listen to dialogic signals and emit signals for pausing player, etc.
	if (Dialogic.timeline_exists(npc_id + "-" + dialogue_id)):
		var dialog = Dialogic.start(npc_id + "-" + dialogue_id)
		add_child(dialog)
		dialogue_viewed(npc_id, dialogue_id)
	else:
		push_error("Unknown dialogue {d_id} for npc {n_id}".format({"d_id": dialogue_id, "n_id": npc_id}))

func get_top_dialogue(npc_id: String) -> Dialogue:
	if (!NPCs.has(npc_id)):
		print("No NPC with id ", npc_id, " exists.")
		return null
	return (NPCs[npc_id] as NPC).get_top_dialogue()
	
func unlock_dialogues(unlocked: Array) -> void:
	for ids in unlocked:
		if (NPCs.has(ids.npc_id)):
			(NPCs[ids.npc_id] as NPC).unlock_dialogue(ids.dialogue_id)

func remove_dialogues(removed: Array) -> void:
	for ids in removed:
		if (NPCs.has(ids.npc_id)):
			(NPCs[ids.npc_id] as NPC).remove_dialogue(ids.dialogue_id)
			
func _lookup_unlock_table(key: String) -> void:
	if (!dialogue_unlock_table.entries.has(key)):
		return
	
	var unlocked_entry: UnlockTableEntry = dialogue_unlock_table.entries[key]
	if (len(unlocked_entry.unlocked_ids) > 0):
		unlock_dialogues(unlocked_entry.unlocked_ids)
	if (len(unlocked_entry.removed_ids) > 0):
		remove_dialogues(unlocked_entry.removed_ids)

func dialogue_viewed(npc_id: String, dialogue_id: String) -> void:
	var key := "npc-{npc_id}-{dialogue_id}".format({"npc_id": npc_id, "dialogue_id": dialogue_id})
	_lookup_unlock_table(key)
	
func choice_selected(choice_id: String, option_selected: int) -> void:
	var key := "choice-{choice_id}-{option}".format({"choice_id": choice_id, "option": option_selected})
	_lookup_unlock_table(key)

func event_viewed(event_tag: String) -> void:
	var key := "world-{event_tag}".format({"event_tag": event_tag})
	_lookup_unlock_table(key)
	
func save() -> void:
	var save_dict := {}
	for npc in NPCs.values():
		save_dict[npc.id] = npc.save()
	var text = JSON.print(save_dict)
	var file = File.new()
	file.open(save_file_name, File.WRITE)
	file.store_string(text)
	file.close()
	
