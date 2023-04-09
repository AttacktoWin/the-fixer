# Author: Marcus

class_name Umbrella extends BaseEnemy

onready var socket_muzzle: Node2D = $FlipComponents/Visual/SocketMuzzle


func get_display_name():
	return "Bird"


func can_attack_hit(info: AttackInfo):
	if (
		self.fsm.current_state_name() in [EnemyState.PAIN, EnemyState.ATTACKING_MELEE, EnemyState.IDLE]
		or info.attack.damage_type != AttackVariable.DAMAGE_TYPE.RANGED
	):
		return true

	var facing = get_x_direction()
	var direction = -sign(info.get_attack_direction(self.global_position).x)
	if (
		self.fsm.current_state_name() != EnemyState.ATTACKING_RANGED
		or not self.fsm.current_state().is_vulnerable()
		or facing != direction
	):
		info.attack.setv(
			AttackVariable.DIRECTION,
			info.get_attack_direction(self.visual.get_node("Sprite").global_position).angle() + PI
		)
		return false
	return true
