# Author: Yalmaz
# Description: Base_State interface extended for goomba
class_name Base_State_Goomba
extends Base_State

onready var p_manager := get_node("%Manager_Enemy")


# Description: temporary method for testing hit animation
func handle_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("ui_right"):
		state_machine.transition_to("STAGGER")


# Description: used to flip sprite based on player position relative to self
func flipSprite():
	var angle = p_manager.get_AngleToPlayer(self)
	if angle < 90 and angle > -90:
		p_context.sprite.flip_h = true
	else:
		p_context.sprite.flip_h = false


########################################################################
#Overrides
########################################################################
func enter(_context) -> void:
	.enter(_context)
	#print out the current state for debuging.
	print("pev: " + p_context.previous_node)
	pass
