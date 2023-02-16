class_name PierceAttackHandler extends AttackHandler

var max_pierce = 1
var _current_pierce = 0


func _init(damage_dealer, damage_owner, hitbox = null, filter = null).(
	damage_dealer, damage_owner, hitbox, filter
):
	pass


#warning-ignore:unused_argument
func _on_hit_success(body: LivingEntity):
	self._current_pierce += 1
	if self._current_pierce >= self.max_pierce:
		self._damage_owner.queue_free()
