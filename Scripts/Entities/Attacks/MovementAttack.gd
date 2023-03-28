class_name MovementAttack extends BaseAttack


func _generate_attack_info(_entity: LivingEntity) -> AttackInfo:
	return AttackInfo.new(
		self._damage_source,
		Vector2(INF, INF),
		self.getv(AttackVariable.DAMAGE),
		self._damage_source.getv(LivingEntityVariable.VELOCITY).normalized().angle(),
		self.knockback_factor,
		self.stun_factor
	)
