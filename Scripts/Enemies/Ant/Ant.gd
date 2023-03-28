# Author: Marcus

class_name Ant extends BaseEnemy


func _on_take_damage(info: AttackInfo):
	if info and self._is_dead:
		if info.damage_source is Player:
			if info.damage_type == AttackVariable.DAMAGE_TYPE.MELEE:
				info.damage_source.add_ammo(2) # +1 implicit from melee
			else:
				info.damage_source.add_ammo(1)
