# Author: Marcus

class_name Umbrella extends BaseEnemy

onready var socket_muzzle: Node2D = $FlipComponents/Visual/SocketMuzzle


func get_entity_name():
	return "Bird"


func can_attack_hit(info: AttackInfo):
	if (
		(
			self.fsm.current_state_name()
			in [EnemyState.PAIN, EnemyState.ATTACKING_MELEE, EnemyState.IDLE]
		)
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
		var fx = preload("res://Scenes/Particles/HitScene.tscn").instance()
		fx.initialize(info.get_attack_direction(self.global_position).angle(), 0)
		Scene.runtime.add_child(fx)
		fx.global_position = info.attack.global_position
		return false

	return true
