extends Base_EnemyFSM
#TODO: lunge height using cart-iso transform

#Hop Parameters
export(int) var hop_distance = 20
export(float) var hop_height = 0.0
export(float) var hop_time = 0.55

#Charge Parameters
export(int) var charge_loop_length = 2

#Lunge Parameters
export(float) var lunge_distance = 160.0
export(float) var lunge_height = 60.0
export(float) var lunge_time = 0.55

var _charge_loop_count = 0


########################################################################
#Context Trigger Methods
########################################################################
func _on_AttackRadius_eneterd(body):
	if body.name == targeting:
		animation_tree.set_condition("in_attack_range", true)


func _on_AttackRadius_exited(body):
	if body.name == targeting:
		animation_tree.set_condition("in_attack_range", false)


########################################################################
#Anim Controled Methods
########################################################################
func ready_hop():
	aim_attack()
	flipSprite()
	var tween := create_tween()
	#warning-ignore:RETURN_VALUE_DISCARDED
	tween.tween_property(
		self,
		"global_position",
		-_attack_dir * hop_distance + self.global_position,
		hop_time
	)


func increment_charge_loop_count():
	_charge_loop_count += 1
	if _charge_loop_count >= charge_loop_length:
		animation_tree.set_condition("attack_ready", true)
		_charge_loop_count = 0


func lunge():
	var tween := create_tween()
	#warning-ignore:RETURN_VALUE_DISCARDED
	tween.tween_property(
		self,
		"global_position",
		_attack_dir * lunge_distance + self.global_position,
		lunge_time
	)


########################################################################
#Life Cycle Methods
###############################i#########################################
func _physics_process(_delta):
	if (!is_instance_valid(animation_tree)):
		return
	var state = animation_tree.state_machine.get_current_node()
	match state:
		"CHASE":
			flipSprite()
			_chase_player()
		"HURT":
			_knock_back(_delta)
