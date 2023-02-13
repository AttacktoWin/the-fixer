# Author: Yalmaz
# Description: Interface to be implemented when making a node
class_name Base_State
extends Node2D

var state_machine: Base_FSM = null
var is_Active: bool = false


func transition_atAnimEnd(next_state: String):
	state_machine.transition_to(next_state)


########################################################################
#Virtual Functions
########################################################################
# Description: Method used to initialize state on entery.
func on_enter() -> void:
	is_Active = true


# Description: Method used to clean up state on exit.
func on_exit():
	update()
	is_Active = false


# Description: Virtual Method that _process for the FSM is delegated to.
func tick(_delta: float) -> void:
	pass


# Description: Virtual Method that _physics_process for the FSM is delegated to.
func physics_tick(_delta: float) -> void:
	pass


# Description: Virtual Method that _unhandled_input for the FSM is delegated to.
func handle_input(_event: InputEvent) -> void:
	pass
