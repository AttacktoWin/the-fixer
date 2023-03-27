# Author: Marcus

class_name PlayerStateDead extends FSMNode


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
	pass
