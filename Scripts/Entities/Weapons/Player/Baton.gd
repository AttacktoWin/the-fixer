# Author: Marcus

class_name PlayerMeleeBaton extends Melee


func _on_attack_hit(entity, _attack: BaseAttack):
	entity.status_timers.delta_timer(LivingEntityStatus.STUNNED, 1.25)
	entity.status_timers.delta_timer(LivingEntityStatus.SLOWED, 2.5)
