extends Base_FSM

export(NodePath) var player_path
export(NodePath) var kb_path
export(float) var speed = 100.0
export(int) var sense_radius = 100
export(int) var attack_radius = 80


func _ready():
	context["player"] = get_node(player_path)
	context["kinematic_body"] = get_node(kb_path)
	context["speed"] = speed
	context["attack_range"] = attack_radius
	context["sense_radius"] = sense_radius
