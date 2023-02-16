class_name Base_AnimatedFSM
extends LivingEntity

export(NodePath) var animation_tree_path
onready var animation_tree := get_node(animation_tree_path)


########################################################################
#Virtual Methods
########################################################################
func on_Anim_change(_prev_state: String, _new_state: String):
	pass


########################################################################
#Life-Cycle
########################################################################
func _ready():
	if animation_tree.connect("node_changed", self, "on_Anim_change") != 0:
		print("FAILED to connect signal")
