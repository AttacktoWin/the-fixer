# Author: Marcus

extends Area2D

export(PackedScene) var to_level
export var long_load: bool = true
export var transfer_player: bool = true
export var fade_time: float = 0.5
var cleared: bool = false

signal on_displayed
signal on_clear_display


func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")  # warning-ignore: RETURN_VALUE_DISCARDED
	connect("body_exited", self, "_on_body_exit")  # warning-ignore: RETURN_VALUE_DISCARDED


func _process(_delta):
	if AI.get_all_enemies().size() == 0:
		cleared = true
		var exit = get_node_or_null("Exit")
		if exit:
			exit.frame = 1


func _on_body_entered(body: Node2D):
	if body is Player and cleared:
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
