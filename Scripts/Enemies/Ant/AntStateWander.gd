# Author: Marcus

class_name AntStateWander extends EnemyStateWander


func get_handled_states():
	return [EnemyState.WANDER, EnemyState.IDLE, EnemyState.CHASING]


func target_set(_target: LivingEntity):
	self.fsm.set_state(EnemyState.RUNNING)


func investigate_target_set(_target: Vector2):
	pass

func _physics_process(delta):
	._physics_process(delta)
	if self.entity.has_target():
		self.target_set(self.entity.get_target())
