# Author: Yalmaz
# Description: Implement FSM interface while specifying it for Goomba enemy
extends Base_FSM

export(NodePath) var sprite_path
export(NodePath) var animator_path
export(float) var speed = 100.0
export(int) var sense_radius = 100
export(int) var attack_radius = 80


########################################################################
#Life Cycle Methods
########################################################################
func _ready():
	context = Context_Goomba.new()

	context.kinematic_body = get_parent()
	context.sprite = get_node(sprite_path)
	context.animator = get_node(animator_path)
	context.speed = speed
	context.sense_radius = sense_radius
	context.attack_radius = attack_radius
	context.previous_node = "ROOT"
