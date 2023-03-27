# Author: Marcus

class_name FSMNode extends Node2D

var fsm = null  # FSMController...
var entity = null


func _init():
	pass


func _ready():
	set_process(false)
	set_physics_process(false)


# called when the node is first added to the FSM
func initialize():
	pass


# can we transition to this state?
func can_transition(_from):
	return true


# if set, automatically switch to this animation when setting this state
func get_animation_name():
	return null


# callback for when the animation ends or loops
# warn: this function may behave erratically if the animation player is seeked
func on_anim_reached_end():
	pass


# boolean which determines if the state can be interrupted (if false, you must use the override flag)
func state_is_interruptable():
	return true


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	print("WARN: get_handled_states not implemented!")
	return []


func enter():
	pass


func exit():
	pass


func _physics_process(_delta):
	pass


func _process(_delta):
	pass

# called before the current state ticks when this state is not the current state
func _background_physics(_delta):
	pass

# called before the current state ticks when this state is not the current state
func _background_process(_deleta):
	pass
