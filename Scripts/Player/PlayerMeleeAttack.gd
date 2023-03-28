# Author: Marcus

class_name PlayerMelee extends BaseAttack

var attack_direction: float = 0


func _on_hit_entity(entity: LivingEntity):
	if entity.is_dead():
		self._damage_source.add_ammo(1)


func _generate_attack_info(_entity: LivingEntity) -> AttackInfo:
	return AttackInfo.new(
		self._damage_source,
		Vector2(INF, INF),
		self.getv(AttackVariable.DAMAGE),
		self.attack_direction,
		self.knockback_factor,
		self.stun_factor
	)
