# Author: Yalmaz
# Description: Generic enemy fsm. Can be extended for more specifc behaviours and stuff.
class_name Generic_EnemyFSM
extends Base_FSM

# movement speed of the enemy.
export(float) var speed = 150.0
# enemy sensing radius.
export(float) var sense_radius = 100.0
# how close the enemy has to be before it can attack.
export(float) var attack_range = 60.0


########################################################################
#Overrides
########################################################################
func p_initializeStates(state):
	.p_initializeStates(state)
	state.sprite = $Visual/Sprite
	state.animator = $Visual/AnimationTree.get("parameters/playback")
	state.player = get_node("%Player_Target")


func transition_to(target_state_name: String, _msg: Dictionary = {}) -> void:
	.transition_to(target_state_name)
	if _current_state.name == "HURT":
		_current_state.hurtInfo = _msg["hurtInfo"]


########################################################################
#Life Cycle Methods
########################################################################
func _ready() -> void:
	._ready()
	$Visual/AnimationTree.active = true


########################################################################
#DEBGU CODE
########################################################################
func debug_draw():
	_current_state.update()
