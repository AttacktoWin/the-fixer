# Author: Marcus

class_name ManifestationStateIdle extends FSMNode

const MIN_DISTANCE = 256


func get_handled_states():
	return [EnemyState.IDLE]


func enter():
	self.fsm.set_animation("IDLE")


func _physics_process(_delta):
	if (self.entity.global_position - Scene.player.global_position).length() < MIN_DISTANCE:
		self.fsm.set_state(EnemyState.ATTACKING_MELEE)
