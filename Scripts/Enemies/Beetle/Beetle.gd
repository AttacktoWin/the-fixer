# Author: Marcus

class_name Beetle extends BaseEnemy


func get_entity_name():
	return "Beetle"


func can_attack_hit(info: AttackInfo):
	if self.fsm.current_state_name() != EnemyState.ATTACKING_MELEE or info.attack.damage_type != AttackVariable.DAMAGE_TYPE.RANGED:
		return true
	
	# melee
	if self.fsm.current_state().is_vulnerable():
		return true
	
	info.attack.setv(
		AttackVariable.DIRECTION,
		info.get_attack_direction(self.visual.get_node("Sprite").global_position).angle() + PI
	)
	return false
	