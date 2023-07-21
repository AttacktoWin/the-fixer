# Author: Marcus

class_name PlayerMelee extends BaseAttack

var attack_direction: float = 0

const AMMO_PARTICLE = preload("res://Scenes/Particles/BulletParticle.tscn")


func _on_hit_entity(entity: LivingEntity):
	AI.notify_sound(entity.global_position, 2048, 2)
	Wwise.post_event_id(AK.EVENTS.HIT_KNUCKLES_PLAYER, Scene)
	if entity.is_dead():
		var part = AMMO_PARTICLE.instance()
		Scene.runtime.add_child(part)
		part.global_position = entity.global_position
		part.set_target(self._damage_source)
		part.set_bounce(not self._damage_source.add_ammo(1))


func _generate_attack_info(_entity: LivingEntity) -> AttackInfo:
	return AttackInfo.new(
		self._damage_source,
		self.damage_type,
		Vector2(INF, INF),
		self,
		ceil(self.getv(AttackVariable.DAMAGE)),
		self.attack_direction,
		self.getv(AttackVariable.KNOCKBACK),
		self.stun_factor
	)
