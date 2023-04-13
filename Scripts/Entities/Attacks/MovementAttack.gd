# Author: Marcus

class_name MovementAttack extends BaseAttack


func _generate_attack_info(_entity: LivingEntity) -> AttackInfo:
	return AttackInfo.new(
		self._damage_source,
		self.damage_type,
		Vector2(INF, INF),
		self,
		ceil(self.getv(AttackVariable.DAMAGE)),
		self._damage_source.getv(LivingEntityVariable.VELOCITY).normalized().angle(),
		ceil(self.getv(AttackVariable.KNOCKBACK)),
		self.stun_factor
	)
