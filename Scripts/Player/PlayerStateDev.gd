# Author: Marcus

class_name PlayerStateDev extends FSMNode


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.DEV]


func enter():
	self.entity.setv(LivingEntity.VARIABLE.VELOCITY, Vector2())
	self.entity.get_node("PhysicsCollider").disabled = true


func exit():
	self.entity.get_node("PhysicsCollider").disabled = false


func _physics_process(_delta):
	var wanted_vel = self.entity._get_wanted_velocity() * 10
	self.entity.setv(LivingEntity.VARIABLE.VELOCITY, wanted_vel)


func _process(_delta):
	pass