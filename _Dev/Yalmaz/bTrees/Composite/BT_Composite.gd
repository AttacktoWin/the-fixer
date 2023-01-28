class_name Base_BT_Composite extends Base_BT_Node
## Author: Yalmaz
## Description: Terminal node in bt called leaf. Can have no child.

var valid: bool = false


# Description: Validates to ensure that root has child.
func validate() -> void:
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
