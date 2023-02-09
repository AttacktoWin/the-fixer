"""
Note1: this is not the right way to do block comments this is a string.
GDScript dosnt have any actual way of doing block comments. Reason im using
it here is to distinguish between comments that you should include in scripts
vs. comments that are notes on style in this style guide.
Note2: ## is used for class comments # is used for comments inside the class.
Note3: If something is not specified here follow the gd-script official style sheet.
"""

# Author: Your name
# Description: Highlevel description of the script and any important usage notes.

"""Order of member declation"""

"""Consts at top"""
const SUCCESS = 0
const FAILURE = 1
const RUNNING = 2

"""Followed by export"""
export(NodePath) var test_path1
export(NodePath) var test_path2
export(NodePath) var test_path3

"""
Protected members to be indicated by leading p_
any protected members will follow public members of same type but preceed
private members.
Private members to be indicated by leading _
any private members will follow protected members of same type but preceed
public members of different type.
"""

export(NodePath) var private_test_path1
export(NodePath) var p_private_test_path2
export(NodePath) var _private_test_path3

"""Any global variables"""
var global_var_A
var global_var_B
var global_var_C


func _ready():
	pass


func _physics_process(_delta):
	pass


func _process(_delta):
	pass


"""
Method naming break from gdScript convention by using camel case. This is to
make it easier to distnguish method from member name. Not neccessary but I will
be using this for my own sanity. If you would like u can also do this.
"""


# Description: plase make sure to document any public facing functions.
# Author: if different author than class.
func customPublic(_valueA: int, _valueB: String) -> void:
	pass
