extends Base_FSM

export(NodePath) var _sprite_path
export(NodePath) var _parent_path
export(NodePath) var _animator_path
export(NodePath) var _player_path

export(float) var speed = 100.0
export(float) var sense_radius = 100.0
export(float) var attack_range = 80.0
export(String) var previous_node = ""

var _is_Flashed = false


func p_initializeStates(state):
	.p_initializeStates(state)
	state.sprite = get_node(_sprite_path)
	state.parent = get_parent()
	state.animator = get_node(_animator_path).get("parameters/playback")
	state.player = get_node("%Player_Target")


########################################################################
#Life Cycle Methods
########################################################################
func _ready() -> void:
	._ready()
	get_node(_animator_path).active = true
