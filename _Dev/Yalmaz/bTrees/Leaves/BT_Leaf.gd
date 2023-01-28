class_name BT_Leaf extends Base_BT_Node
## Author: Yalmaz
## Description: Terminal node in bt called leaf. Can have no child.


# Description: Validates to ensure that leaf is being used correctly.
func validate() -> void:
	var children = get_children()
	if children.size() != 0:
		print("BTree Warning:")
		print("Leaf child can have no child. They will not be processed")
