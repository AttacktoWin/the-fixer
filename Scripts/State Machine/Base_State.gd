# Author: Yalmaz
# Description: Interface to be implemented when making a node
class_name Base_State
extends Node2D

# warning-ignore:UNUSED_SIGNAL
signal cleanup_finished  # signal emitted when clean up complete and ready to transition

var state_machine: Base_FSM = null
var is_cleaningUp: bool = false


# Description: Method used to initialize state on entery.
# `_context` current context passed in from the state_machine
func enter() -> void:
	pass


# Description: Method used to clean up state on exit.
# return context that has been modified by the state
func exit():
	pass


# Description: Virtual Method to that _process for the FSM is delegated to.
func tick(_delta: float) -> void:
	pass


# Description: Virtual Method to that _physics_process for the FSM is delegated to.
func physics_tick(_delta: float) -> void:
	pass
