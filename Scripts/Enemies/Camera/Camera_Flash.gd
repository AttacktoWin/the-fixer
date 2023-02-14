# Author: Yalmaz
# Description: Flash state for the spyder handles the logic for flash attack
extends Base_EnemyState


########################################################################
#Overrides
########################################################################
func on_exit() -> void:
	state_machine.is_flashON = true


func tick(_delta: float) -> void:
	#handle flash logic here
	pass
