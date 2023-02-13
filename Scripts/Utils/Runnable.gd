class_name Runnable extends Object

var _parent = null


func with_parent(parent):
	self._parent = parent
	return self


func get_parent():
	return self._parent


# runnable list is responsible for updating this... We do it this way so we can copy these nodes as data classes
# warning-ignore:unused_argument
func tick(delta):
	pass


# warning-ignore:unused_argument
func clone(new_parent):
	print("Not implemented!!!")


func run(_arg):
	print("Not implemented!!!")
