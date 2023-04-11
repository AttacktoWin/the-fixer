tool
extends Node


const NPC = preload("res://Scripts/DialogueSystem/NPC.gd")
const DialogueNPCIds = preload("res://Scripts/DialogueSystem/classes/DialogueNpcIds.gd")
const Dialogue = preload("res://Scripts/DialogueSystem/classes/Dialogue.gd")

export var dialogue_unlock_table: Resource
export var save_file_name: String = ""

var NPCs: Dictionary = {}
var current_npc_id := ""
var current_dialogue_id := ""

var current_dialog_box: CanvasLayer
var follow_player := false

const enemy_timelines := {
	"pillbug": ["1-pillbug"],
	"spyder": ["1-spyder"],
	"beetle": ["1-beetle"],
	"bird": ["1-bird"],
	"ant": []
}


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
	if (save_dict.has("stats")):
		StatsTracker.init(save_dict["stats"])
	
	Scene.connect("world_updated", self, "level_started")
	Scene.connect("transition_start", self, "level_changed")
	
	Wwise.register_listener(self)
	Wwise.register_game_obj(self, "DialogueSystem")
		
	if (Engine.editor_hint):
		print("Loaded Dialogue System in {time} usec.".format({"time": Time.get_ticks_usec() - init_time}))
		
func _process(_delta):
	if (is_instance_valid(self.current_dialog_box) && follow_player):
		var player = get_parent().get_node("World/Level/SortableEntities/Player")
		if (is_instance_valid(player)):
			current_dialog_box.offset = MathUtils.from_iso(player.position - Vector2(40, 900))
		
func display_dialogue(npc_id: String, dialogue_id: String, bubble = false) -> void:
	if (Dialogic.timeline_exists(npc_id + "-" + dialogue_id)):
		var dialog: Node
		dialog = Dialogic.start(npc_id + "-" + dialogue_id)
		if (bubble):
			follow_player = true
			dialog.follow_viewport_enable = true
			dialog.scale = Vector2(0.75, 1.5)
		self.current_npc_id = npc_id
		self.current_dialogue_id = dialogue_id
		dialog.connect("timeline_end", self, "_timeline_end")
		dialog.connect("dialogic_signal", self, "_signal_listener")
		self.current_dialog_box = dialog
		add_child(dialog)
	else:
		push_error("Unknown dialogue {d_id} for npc {n_id}".format({"d_id": dialogue_id, "n_id": npc_id}))

func _timeline_end(_t_name: String):
	dialogue_viewed(self.current_npc_id, self.current_dialogue_id)
	self.current_dialog_box = null
	self.follow_player = false
	if (PausingSingleton._paused):
		PausingSingleton.unpause()

func _signal_listener(s_name: String):
	match s_name:
		"pause":
			PausingSingleton.pause()
			$CanvasLayer.show()
			$CanvasLayer/Tween.interpolate_property($CanvasLayer/ColorRect, "modulate", $CanvasLayer/ColorRect.modulate, Color(1, 1, 1, 0.5), 0.2)
			$CanvasLayer/Tween.start()
		"unpause":
			PausingSingleton.unpause()
			$CanvasLayer/Tween.interpolate_property($CanvasLayer/ColorRect, "modulate", $CanvasLayer/ColorRect.modulate, Color(1, 1, 1, 0), 0.2)
			$CanvasLayer/Tween.interpolate_callback($CanvasLayer, 0.2, "hide")
			$CanvasLayer/Tween.start()
		"hide_screen":
			$CanvasLayer.show()
			$CanvasLayer/Tween.interpolate_property($CanvasLayer/ColorRect, "modulate", $CanvasLayer/ColorRect.modulate, Color(1, 1, 1, 1), 0.2)
			$CanvasLayer/Tween.start()
		"reveal_screen":
			$CanvasLayer/Tween.interpolate_property($CanvasLayer/ColorRect, "modulate", $CanvasLayer/ColorRect.modulate, Color(1, 1, 1, 0), 0.2)
			$CanvasLayer/Tween.interpolate_callback($CanvasLayer, 0.2, "hide")
			$CanvasLayer/Tween.start()
		"shake_screen":
			CameraSingleton.shake(0.5)
		"bubble":
			self.current_dialog_box.follow_viewport_enable = true
			self.current_dialog_box.scale = Vector2(0.75, 1.5)
			self.follow_player = true
		"credits":
			# Stop hub music and play credits music
			pass
		"stop_credits":
			# Stop credits music and start hub music
			pass
			
func play_sound(sound_id: String):
	if (AK.EVENTS._dict.has(sound_id)):
		Wwise.post_event_id(AK.EVENTS._dict[sound_id], self)

func get_top_dialogue(npc_id: String) -> Dialogue:
	if (!NPCs.has(npc_id)):
		print("No NPC with id ", npc_id, " exists.")
		return null
	return (NPCs[npc_id] as NPC).get_top_dialogue()
	
func unlock_dialogues(unlocked: Array) -> void:
	unlocked.shuffle()
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
	var key := "event-{event_tag}".format({"event_tag": event_tag})
	_lookup_unlock_table(key)
	
func level_started():
	if (NPCs["fixer"].peek_top_dialogue().priority == Dialogue.Priority.STORY):
		return
	var enemies = AI.get_all_enemies()
	if (len(enemies) == 0 || randi() % 100 >= 50):
		return
	var index = randi() % len(enemies)
	var e_name = enemies[index].get_entity_name().to_lower()
	if (e_name in self.enemy_timelines.keys() && len(self.enemy_timelines[e_name]) > 0):
		var timeline = self.enemy_timelines[e_name][randi() % len(self.enemy_timelines[e_name])]
		NPCs["fixer"].unlock_dialogue(timeline)
		
	
func level_changed():
	if NPCs["fixer"].peek_top_dialogue().priority == Dialogue.Priority.SPECIFIC:
		NPCs["fixer"].get_top_dialogue()
		
	
func save() -> void:
	var save_dict := {}
	for npc in NPCs.values():
		save_dict[npc.id] = npc.save()
	save_dict["stats"] = StatsTracker.save()
	var text = JSON.print(save_dict)
	var file = File.new()
	file.open(save_file_name, File.WRITE)
	file.store_string(text)
	file.close()
	
