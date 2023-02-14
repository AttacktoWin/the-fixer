# Author: Yalmaz
# Description: Chase state specific to the spyder enemy
extends Generic_CHASE

# this node can have two possible transitions. This specifies the second
export(String) var alternative_node = "FLASH"


########################################################################
#Overrides
########################################################################
func physics_tick(_delta: float) -> void:
	flipSprite()
	if _chasePlayer(
		(
			state_machine.attack_range
			if (state_machine.is_flashON)
			else state_machine.flash_range
		)
	):
		animator.travel(
			next_node if (state_machine.is_flashON) else alternative_node
		)
