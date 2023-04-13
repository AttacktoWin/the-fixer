# Author: Marcus

class_name PlayerStateDead extends FSMNode

const WAIT_TIME = 2.0
var _timer = 0


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.DEAD]


func enter():
	self.entity.setv(LivingEntityVariable.VELOCITY, Vector2())
	self.fsm.set_animation("DIE")


func exit():
	pass


func _physics_process(_delta):
	pass


func _process(_delta):
	self._timer += _delta
	if self._timer > WAIT_TIME:
		TransitionHelper.transition(load("res://Scenes/Levels/Hub.tscn").instance(), false, false)
