class_name BT_Blackboard extends Node
## Author: Yalmaz
## Description: BlackBoard stores data for the behaviour tree to allow for
## behaviour that presists over multiple frames.

var _black_board: Dictionary = {}


# Description: sets the value in blackboard. Supports the creation of multiple
# sub boards. Name of the sub board is given through boar_name param.
func setValue(key, value, boar_name: String = "default") -> void:
	if not _black_board.has(boar_name):
		_black_board[boar_name] = {}
	_black_board[boar_name][key] = value


# Description: gets the value in blackboard. Supports the specification of specific
# sub boards. Name of the sub board is given through board_name param.
func getValue(key, default_value = null, board_name: String = "default"):
	if hasValue(key, board_name):
		return _black_board[board_name].get(key, default_value)
	return default_value


# Description: check to see if key is in a particular blackboard.
func hasValue(key, board_name: String = "default") -> bool:
	return (
		_black_board.has(board_name)
		and _black_board[board_name].has(key)
		and _black_board[board_name][key] != null
	)


# Description: erase specific key in a particular blackboard.
func eraseValue(key, board_name: String = "default") -> void:
	if _black_board.has(board_name):
		_black_board[board_name][key] = null
