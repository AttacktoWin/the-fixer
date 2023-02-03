class_name Base_BT_Node extends BT
## Author: Yalmaz
## Description: Abstract base for nodes in behaviour tree.


# Description: tick is the function is the function that handles node processing.
# This function must return a _status code.
func tick(_delta, _black_board, _actor) -> int:
	return SUCCESS
