# Author: Yalmaz
# Description: Abstract FSM class. controls the state trasitions for this state patten.
class_name Base_FSM
extends KinematicBody2D

# Path for the state node that this fsm should initalize with.
export(NodePath) var initial_state_path
var previous_node
onready var _current_state = get_node(initial_state_path)


# Description: Method used to initalize the states on ready.
func p_initializeStates(state) -> void:
	state.state_machine = self


# Description: Method used to transition the state.
# Params `target_state_name`:  specifies the state being transitioned to. This must be the same as the name of state node in scene.
# Params `_msg`: pass any message that the state needs to relay back to the fsm.
func transition_to(target_state_name: String, _msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return

	#call clean up for current state
	_current_state.on_exit()

	#prepare and connect next state
	var next_state = get_node(target_state_name)
	next_state.previous_state = _current_state.name
	_current_state = next_state
	_current_state.on_enter(_msg)


########################################################################
#Life Cycle Methods
########################################################################
func _ready() -> void:
	for child in get_children():
		if child.has_method("tick"):
			p_initializeStates(child)
	if _current_state != null:
		_current_state.on_enter()


func _process(delta: float) -> void:
	if _current_state != null:
		_current_state.tick(delta)


func _physics_process(delta: float) -> void:
	if _current_state != null:
		_current_state.physics_tick(delta)


func _unhandled_input(event: InputEvent) -> void:
	if _current_state != null:
		_current_state.handle_input(event)
