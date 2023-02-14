# Author: Yalmaz
# Description: Generic state that handles chasing behaviour
class_name Generic_CHASE extends Base_EnemyState

# next animator fsm node to travel to
export(String) var next_node = "GET_READY"


func _chasePlayer(attack_range: float) -> bool:
	if is_PlayerInRange(self, attack_range):
		return true
	elif animator.get_current_node() == "CHASE":
		# warning-ignore:UNUSED_VARIABLE
		var velocity = state_machine.move_and_slide(
			state_machine.speed * get_DirectionToPlayer(self)
		)
	return false


########################################################################
#Overrides
########################################################################
func physics_tick(_delta: float) -> void:
	flipSprite()
	if _chasePlayer(state_machine.attack_range):
		animator.travel(next_node)


########################################################################
#DEBGU CODE
########################################################################
func _draw():
	if is_Active:
		draw_line(Vector2.ZERO, get_PlayerInLocal(self), Color.white)
		draw_line(
			Vector2.ZERO,
			get_DirectionToPlayer(self) * state_machine.attack_range,
			Color.blue,
			4
		)
