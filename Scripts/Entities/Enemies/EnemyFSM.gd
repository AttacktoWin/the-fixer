class_name Base_EnemyFSM
extends Base_AnimatedFSM

export(String) var targeting = "Player"
var target = null

var movement_speed = 90

var _attack_dir = Vector2.ZERO


func _on_take_damage(_amount: float, _meta: HitMetadata):
	var bar = self.get_node("ProgressBar")
	bar.value = (self._getv(LivingEntity.VARIABLE.HEALTH) / self.base_health) * 100


func _on_death():
	self.queue_free()  # YALMAZ ANIMATION HERE (DEATH ANIM)


func aim_attack():
	if target != null:
		_attack_dir = (target.global_position - self.global_position).normalized()


func flipSprite():
	if target:
		var angle = rad2deg(self.get_angle_to(target.global_position))
		if angle < 90 and angle > -90:
			self.scale.x = -1
		else:
			self.scale.x = 1


########################################################################
#Context Trigger Methods
########################################################################
func _on_SenseRadius_eneterd(body):
	if body.name == targeting:
		target = body
		animation_tree.set_condition("player_found", true)


########################################################################
#Tick Methods
########################################################################
func _chase_player() -> void:
	var _velocity = self.move_and_slide(
		(
			(movement_speed * Vector2(2, 1))
			* (target.global_position - self.global_position).normalized()
		)
	)
