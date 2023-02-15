extends LivingEntity
#TODO: lunge height using cart-iso transform

export(String) var targeting = "Player"
export(NodePath) var animation_tree_path
onready var animation_tree := get_node(animation_tree_path)

var target = null

var charge_loop_count = 0
var charge_loop_length = 2

var movement_speed = 90

var _attack_dir = Vector2.ZERO

var hop_distance = 20
var hop_height = 0.0
var hop_time = 0.55

var lunge_distance = 160.0
var lunge_height = 60.0
var lunge_time = 0.55


func aim_attack():
	if target != null:
		_attack_dir = (target.global_position - self.global_position).normalized()


func flipSprite():
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


func _on_AttackRadius_eneterd(body):
	if body.name == targeting:
		animation_tree.set_condition("in_attack_range", true)


func _on_AttackRadius_exited(body):
	if body.name == targeting:
		animation_tree.set_condition("in_attack_range", false)


func on_Anim_change(_prev_state: String, _new_state: String):
	pass


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
	charge_loop_count += 1
	if charge_loop_count >= charge_loop_length:
		animation_tree.set_condition("attack_ready", true)
		charge_loop_count = 0


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
#Tick Methods
########################################################################
func _chase_player() -> void:
	var _velocity = self.move_and_slide(
		(
			(movement_speed * Vector2(2, 1))
			* (target.global_position - self.global_position).normalized()
		)
	)


########################################################################
#Life Cycle Methods
###############################i#########################################
func _ready():
	if animation_tree.connect("node_changed", self, "on_Anim_change") != 0:
		print("FAILED to connect signal")


func _physics_process(_delta):
	var state = animation_tree.state_machine.get_current_node()
	match state:
		"CHASE":
			flipSprite()
			_chase_player()
