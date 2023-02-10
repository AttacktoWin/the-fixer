# Author: Yalmaz
# Description: Interface to implement FSM. controls the state trasitions for this state patten.
class_name Base_FSM
extends Node2D

export(NodePath) var initial_state_path

var context := Context  # Context passed into the states allows information to be passed betewen states. This could be a dict or custom data type
onready var current_state: Base_State = get_node(initial_state_path)


func set_manager(val):
	print(val)
	context.manager = val


# Description: Method used to transition the state.
# Params `target_state_name`:  specifies the state being transitioned to. This must be the same as the name of state node in scene.
# Params `_msg`: pass any message that the state needs to relay back to the fsm.
func transition_to(target_state_name: String, _msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return

	#call clean up for current state
	context = current_state.exit()

	#wait for state to finish clean up
	yield(current_state, "cleanup_finished")

	#prepare and connect next state
	current_state = get_node(target_state_name)
	current_state.enter(context)


########################################################################
#Life Cycle Methods
########################################################################
func _ready() -> void:
	yield(owner, "ready")
	for child in get_children():
		if child.has_method("tick"):
			child.state_machine = self
	current_state.enter(context)


func _process(delta: float) -> void:
	current_state.tick(delta)


func _physics_process(delta: float) -> void:
	current_state.physics_tick(delta)


func _unhandled_input(event: InputEvent) -> void:
	current_state.handle_input(event)
