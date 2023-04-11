# Author: Marcus

class_name LocationAttack extends BaseAttack


func _generate_attack_info(entity: LivingEntity) -> AttackInfo:
	return AttackInfo.new(
		self._damage_source,
		self.damage_type,
		self.global_position,
		self,
		self.getv(AttackVariable.DAMAGE),
		(entity.global_position - self.global_position).angle(),
		self.getv(AttackVariable.DAMAGE),
		self.stun_factor
	)
