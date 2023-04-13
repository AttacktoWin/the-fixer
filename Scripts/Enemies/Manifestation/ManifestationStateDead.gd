# Author: Marcus

class_name ManifestationStateDead extends FSMNode


func get_handled_states():
	return [ManifestationState.DEAD]


func enter():
	for enemy in AI.get_all_enemies():
		enemy.kill()
	self.fsm.set_animation("DEATH")


func exit():
	pass
