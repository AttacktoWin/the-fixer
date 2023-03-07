class_name Base_EnemyFSM
extends Base_AnimatedFSM

export(String) var targeting = "Player"
var target = null

var movement_speed = 90

var _hitstun_loop_count = 0
var _attack_dir = Vector2.ZERO
var _knock_back_dir = Vector2.ZERO
var _knock_back_speed = 2
var _knock_back_friction = 10


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
#Anim Controled Methods
########################################################################
func increment_hurt_loop_count():
	_hitstun_loop_count += 1
	if _hitstun_loop_count >= 3:
		animation_tree.set_condition("hit_stun_over", true)
		_hitstun_loop_count = 0


########################################################################
#Context Trigger Methods
########################################################################
func _on_SenseRadius_eneterd(body):
	if body.name == targeting:
		target = body
		animation_tree.set_condition("player_found", true)


########################################################################
#Override
########################################################################
func _on_take_damage(_amount: float, _meta: HitMetadata):
	var bar = self.get_node("ProgressBar")
	bar.value = ((self.getv(LivingEntity.VARIABLE.HEALTH) / self.base_health) * 100)

	#knockback
	#TODO really need to redo this without the hard coded values
	_knock_back_speed = 2
	_knock_back_dir = _meta.direction
	#play hurt animation
	animation_tree.state_machine.start("HURT")
	target = _meta.owner


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


func _knock_back(delta) -> void:
	_knock_back_speed = clamp(_knock_back_speed - delta * _knock_back_friction, 0, 10)
	#warning-ignore:RETURN_VALUE_DISCARDED
	move_and_collide(_knock_back_dir * _knock_back_speed)
