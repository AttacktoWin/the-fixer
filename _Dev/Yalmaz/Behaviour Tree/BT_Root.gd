class_name BT_Root extends BT
## Author: Yalmaz
## Description: Root for the behaviour tree (bt). Needs to have children
## otherwise it will throw a warning. bt does its ticks in _process so please
## only use it for logic of identifying what to execute. Actual functions should
## be called in the actor.

onready var _black_board = BT_Blackboard.new()
export(NodePath) var actor_path

var valid: bool = false
var actor: Node


func _ready():
	actor = get_node(actor_path)
	_validate()


func _process(delta):
	if valid:
		tick(delta)


# Description: tick is the function is the function that handles node processing
# at root level this simply calls tick() int the first child. which recursivly
# calls tick in its kids.
func tick(delta):
	_black_board.set("delta", delta)
	self.get_child(0).tick(_black_board, actor)


# Description: Validates to ensure that root has child.
func _validate() -> void:
	var children = get_children()
	if children.size() == 0:
		print("BTree Warning:")
		print("Needs to have child. No point otherwise.")
		valid = false
		return

	for child in children:
		if not child.has_method("tick"):
			print("BTree Warning:")
			print("Has child that is not b-tree node. Please remove")
			valid = false
			return

	self.get_child(0).validate()
