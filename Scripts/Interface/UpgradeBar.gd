extends Node

# Called when the node enters the scene tree for the first time.
var bar_units = []
func _ready():
	bar_units = get_children()
	print(bar_units)

func _set_active(count)->bool:
	if count>bar_units.size():
		return false
	for i in count:
		bar_units[i].frame = 1
	return true
