class_name EnemyFSM
extends Base_FSM

export(float) var speed = 150.0
export(float) var sense_radius = 100.0
export(float) var attack_range = 60.0


func debug_draw():
	_current_state.update()


########################################################################
#Overrides
########################################################################
func p_initializeStates(state):
	.p_initializeStates(state)
	state.sprite = $Visual/Sprite
	state.animator = $Visual/AnimationTree.get("parameters/playback")
	state.player = get_node("%Player_Target")


########################################################################
#Life Cycle Methods
########################################################################
func _ready() -> void:
	._ready()
	$Visual/AnimationTree.active = true
