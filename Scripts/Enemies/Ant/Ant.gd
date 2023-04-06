# Author: Marcus

class_name Ant extends BaseEnemy

const AMMO_PARTICLE = preload("res://Scenes/Particles/BulletParticle.tscn")

func _spawn_particle(entity: LivingEntity):
	var part = AMMO_PARTICLE.instance()
	Scene.runtime.add_child(part)
	part.global_position = self.global_position
	part.set_target(entity)

func _on_take_damage(info: AttackInfo):
	._on_take_damage(info)
	if info and self._is_dead:
		if info.damage_source is Player:
			if info.damage_type == AttackVariable.DAMAGE_TYPE.MELEE:
				self._spawn_particle(info.damage_source)
				self._spawn_particle(info.damage_source)
				info.damage_source.add_ammo(2)  # +1 implicit from melee
			else:
				self._spawn_particle(info.damage_source)
				info.damage_source.add_ammo(1)
