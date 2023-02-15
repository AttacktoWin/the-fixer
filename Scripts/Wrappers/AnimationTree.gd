extends AnimationTree
onready var sprite = $"Visual/Sprite"
onready var state_machine = self.get("parameters/playback")

signal node_changed

var prev_state = ""
var curr_state = ""


func set_condition(condition_name: String, value):
	set("parameters/conditions/" + condition_name, value)


func _ready():
	curr_state = state_machine.get_current_node()
	prev_state = curr_state


func _process(_delta):
	var animator_state = state_machine.get_current_node()
	if curr_state != animator_state:
		prev_state = curr_state
		curr_state = animator_state
		self.emit_signal("node_changed", prev_state, curr_state)
