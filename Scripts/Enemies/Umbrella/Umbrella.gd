# Author: Marcus

class_name Umbrella extends BaseEnemy

onready var socket_muzzle: Node2D = $FlipComponents/Visual/SocketMuzzle


func can_attack_hit(info: AttackInfo):
	if self.fsm.current_state_name() == EnemyState.PAIN or not info.attack.is_ranged:
		return true

	var facing = get_x_direction()
	var direction = -sign(info.get_attack_direction(self.global_position).x)
	if (
		self.fsm.current_state_name() != EnemyState.ATTACKING_RANGED
		or not self.fsm.current_state().is_vulnerable()
		or facing != direction
	):
		if info.attack.is_ranged:
			info.attack.setv(
				AttackVariable.DIRECTION,
				(
					info.get_attack_direction(self.visual.get_node("Sprite").global_position).angle()
					+ PI
				)
			)
		return false
	return true
