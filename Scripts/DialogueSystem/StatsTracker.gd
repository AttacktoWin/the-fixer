extends Node

var manifestation_wins := 0
var manifestation_fights := 0
var deaths := 0
var watched_ending := false


func add_manifestation_win():
	self.manifestation_wins += 1
	if self.manifestation_wins < 13:
		DialogueSystem.event_viewed(
			"manifestation{count}win".format({"count": self.manifestation_wins})
		)
		if self.manifestation_wins >= 10:
			DialogueSystem.call_deferred(
				"display_dialogue",
				"fixer",
				"post{count}win".format({"count": self.manifestation_wins})
			)
	if self.manifestation_wins == 12:
		TransitionHelper.transition(load("res://Scenes/Levels/Hub.tscn").instance(), false, false)


func add_manifestation_fight():
	self.manifestation_fights += 1
	if self.manifestation_fights == 100:
		DialogueSystem.event_viewed("100manifestation")


func add_death(cause: String = ""):
	self.deaths += 1
	if (cause && randi() % 100 <= 40):
		DialogueSystem.event_viewed("1-" + cause.to_lower() + "kill")
	Dialogic.set_variable("deaths", self.deaths)


func save():
	return {
		"manifestation_wins": self.manifestation_wins,
		"manifestation_fights": self.manifestation_fights,
		"deaths": self.deaths,
		"watched_ending": self.watched_ending
	}


func init(save_dict: Dictionary):
	if save_dict.has("manifestation_wins"):
		self.manifestation_wins = save_dict["manifestation_wins"]
	if save_dict.has("manifestation_fights"):
		self.manifestation_fights = save_dict["manifestation_fights"]
	if save_dict.has("deaths"):
		self.deaths = save_dict["deaths"]
	if save_dict.has("watched_ending"):
		self.watched_ending = save_dict["watched_ending"]
	
	# Queue up the ending if they haven't seen it yet and it isn't queued
	if !self.watched_ending && self.manifestation_wins >= 12 \
	&& DialogueSystem.peek_top_dialogue("boss").priority != Dialogue.Priority.SPECIFIC:
		var unlocked = DialogueNPCIds.new()
		unlocked.npc_id = "boss"
		unlocked.dialogue_id = "manifestation12win"
		DialogueSystem.unlock_dialogues([unlocked])
