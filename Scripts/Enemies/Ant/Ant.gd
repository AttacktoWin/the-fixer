# Author: Marcus

class_name Ant extends BaseEnemy

const AMMO_PARTICLE = preload("res://Scenes/Particles/BulletParticle.tscn")


func get_entity_name():
	return "Ant"


func _try_add_ammo(entity: LivingEntity):
	var part = AMMO_PARTICLE.instance()
	Scene.runtime.add_child(part)
	part.global_position = self.global_position
	part.set_target(entity)
	part.set_bounce(not entity.add_ammo(1))


func _on_take_damage(info: AttackInfo):
	._on_take_damage(info)
	if info and self._is_dead:
		if info.damage_source is Player:
			if info.damage_type == AttackVariable.DAMAGE_TYPE.MELEE:
				self._try_add_ammo(info.damage_source)
				self._try_add_ammo(info.damage_source)
			else:
				self._try_add_ammo(info.damage_source)
