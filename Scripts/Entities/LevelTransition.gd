# Author: Marcus

extends Area2D

export(PackedScene) var to_level
export var long_load: bool = true
export var transfer_player: bool = true
export var fade_time: float = 0.5
export var spawn_upgrades: bool = true
var cleared: bool = false
var _upgrades = null

signal on_displayed
signal on_clear_display


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")  # warning-ignore: RETURN_VALUE_DISCARDED
	connect("body_exited", self, "_on_body_exit")  # warning-ignore: RETURN_VALUE_DISCARDED


func _process(_delta):
	if AI.get_all_enemies().size() == 0 and not self.cleared:
		self.cleared = true
		if self.spawn_upgrades:
			self._upgrades = DualUpgrade.new()
			Scene.runtime.add_child(self._upgrades)
			self._upgrades.global_position = self.global_position
			get_node_or_null("Node2D/ExitMessage").text = "Select an upgrade (e)"
	if self.cleared and (not self._upgrades or self._upgrades.is_collected()):
		self._upgrades = null
		var exit = get_node_or_null("Exit")
		if exit:
			exit.frame = 1


func _on_body_entered(body: Node2D):
	if body is Player and self.cleared and self._upgrades == null:
		self.call_deferred("_transition")
	elif body is Player:
		var exit = get_node_or_null("Node2D/ExitMessage")
		if exit:
			exit.visible = true
			emit_signal("on_displayed")


func _on_body_exit(body: Node2D):
	if body is Player:
		var exit = get_node_or_null("Node2D/ExitMessage")
		if exit:
			exit.visible = false
			emit_signal("on_clear_display")


func _transition():
	var inst = to_level.instance()
	TransitionHelper.transition(inst, long_load, transfer_player, fade_time)
