# Author: Marcus

class_name EnemyStateChase extends EnemyStateMoving


func get_handled_states():
	return [EnemyState.CHASING]


func enter():
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, false)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_LINE_COLOR, Constants.COLOR.YELLOW)


func _physics_process(delta):
	if not self.entity.has_target():
		self.fsm.set_state(EnemyState.IDLE)
		return
	var vel = self.entity.get_wanted_velocity(self.entity.get_wanted_direction())
	_try_move(delta, vel)
	_update_visuals()
	if entity.status_timers.get_timer(LivingEntityStatus.STUNNED) > 0:
		return
	if AI.has_LOS(self.entity.global_position, self.entity.get_target().global_position):
		var dist = (self.entity.get_target().global_position - self.entity.global_position).length()
		if (
			self.entity.has_melee_attack
			and dist < self.entity.melee_attack_range
			and self.fsm.can_transition_to(EnemyState.ATTACKING_MELEE)
		):
			self.fsm.set_state(EnemyState.ATTACKING_MELEE)
		elif (
			self.entity.has_ranged_attack
			and dist < self.entity.ranged_attack_range
			and self.fsm.can_transition_to(EnemyState.ATTACKING_RANGED)
		):
			self.fsm.set_state(EnemyState.ATTACKING_RANGED)

# func _draw():
# 	if self.entity.get_nav_path():
# 		self.entity.get_nav_path().draw(self)
