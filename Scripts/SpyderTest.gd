extends LivingEntity
#TODO: lunge height using cart-iso transform

export(String) var targeting = "Player"
export(NodePath) var animation_tree_path
export(NodePath) var attack_validator_path
onready var animation_tree := get_node(animation_tree_path)
onready var attack_validator := get_node(attack_validator_path)
var target = null

var movement_speed = 180
export var flash_used = false

var charge_loop_count = 0
var charge_loop_length = 1


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


func _on_FlashRange_eneterd(body):
	if body.name == targeting and not flash_used:
		flipSprite()
		animation_tree.set_condition("in_flash_range", true)


func _on_FlashRange_exited(body):
	if body.name == targeting:
		animation_tree.set_condition("in_flash_range", false)


func _on_AttackVlaidator_eneterd(body):
	if body.name == targeting and flash_used:
		animation_tree.set_condition("in_slash_range", true)


func _on_AttackVlaidator_exited(body):
	if body.name == targeting:
		animation_tree.set_condition("in_slash_range", false)


func on_Anim_change(_prev_state: String, _new_state: String):
	pass


########################################################################
#Anim Controled Methods
########################################################################
func increment_charge_loop_count():
	charge_loop_count += 1
	if charge_loop_count >= charge_loop_length:
		animation_tree.set_condition("flash_ready", true)
		charge_loop_count = 0


########################################################################
#Tick Methods
########################################################################
func _chase_player() -> void:
	var _velocity = self.move_and_slide(
		(
			(movement_speed * Vector2(2, 1))
			* (target.global_position - attack_validator.global_position).normalized()
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
	print(flash_used)
	match state:
		"CHASE":
			flipSprite()
			_chase_player()
