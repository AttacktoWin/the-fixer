# Author: Marcus

class_name PlayerMelee extends BaseAttack

var attack_direction: float = 0


func _on_hit_entity(entity: LivingEntity):
	Wwise.post_event_id(AK.EVENTS.HIT_KNUCKLES_PLAYER, self._damage_source)
	if entity.is_dead():
		self._damage_source.add_ammo(1)


func _generate_attack_info(_entity: LivingEntity) -> AttackInfo:
	return AttackInfo.new(
		self._damage_source,
		self.damage_type,
		Vector2(INF, INF),
		self,
		self.getv(AttackVariable.DAMAGE),
		self.attack_direction,
		self.knockback_factor,
		self.stun_factor
	)
