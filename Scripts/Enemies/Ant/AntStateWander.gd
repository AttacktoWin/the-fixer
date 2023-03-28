# Author: Marcus

class_name AntStateWander extends EnemyStateWander

func target_set(_target: LivingEntity):
	self.fsm.set_state(EnemyState.RUNNING)