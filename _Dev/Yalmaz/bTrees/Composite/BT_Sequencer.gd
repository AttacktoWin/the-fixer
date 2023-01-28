class_name BT_Sequencer extends Base_BT_Composite
## Author: Yalmaz
## Description: Terminal node in bt called leaf. Can have no child.


# Description: Sequencer runs all the nodes untill one fails.
func tick(_delta, _black_board, _actor) -> int:
	var response = FAILURE
	if valid:
		var children = get_children()
		for child in children:
			response = child.tick(_delta, _black_board, _actor)
			if response == FAILURE:
				return FAILURE
			elif response == RUNNING:
				return RUNNING
	return response
