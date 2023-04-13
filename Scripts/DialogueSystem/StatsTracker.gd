extends Node

var manifestation_wins := 0
var manifestation_fights := 0
var deaths := 0


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


func add_manifestation_fight():
	self.manifestation_fights += 1
	if self.manifestation_fights == 100:
		DialogueSystem.event_viewed("100manifestation")


func add_death(cause: String = ""):
	self.deaths += 1
	if (cause && randi() % 100 <= 40):
		DialogueSystem.event_viewed("1-" + cause + "kill")
	Dialogic.set_variable("deaths", self.deaths)


func save():
	return {
		"manifestation_wins": self.manifestation_wins,
		"manifestation_fights": self.manifestation_fights,
		"deaths": self.deaths
	}


func init(save_dict: Dictionary):
	if save_dict.has("manifestation_wins"):
		self.manifestation_wins = save_dict["manifestation_wins"]
	if save_dict.has("manifestation_fights"):
		self.manifestation_fights = save_dict["manifestation_fights"]
	if save_dict.has("deaths"):
		self.deaths = save_dict["deaths"]
