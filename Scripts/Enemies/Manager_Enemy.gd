extends Node2D

var enemies = []


########################################################################
#Life Cycle Functions
########################################################################
func _process(_delta):
	get_tree().call_group("Enemy", "debug_draw")
	pass
