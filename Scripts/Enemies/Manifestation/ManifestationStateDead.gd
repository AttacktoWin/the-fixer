# Author: Marcus

class_name ManifestationStateDead extends FSMNode


func get_handled_states():
	return [EnemyState.DEAD]


func enter():
	for enemy in AI.get_all_enemies():
		enemy.kill()
	self.fsm.set_animation("DEATH")


func _on_anim_complete(_anim: String):
	self.entity.queue_free()


func exit():
	pass
