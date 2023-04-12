extends Node

# Called when the node enters the scene tree for the first time.
var bar_units = []
var active_units = 0
func _ready():
	bar_units = get_children()
	set_active(active_units)

func set_active(count)->bool:
	if count>bar_units.size():
		return false
	for i in count:
		bar_units[i].frame = 1
	return true

func increment():
	active_units+=1
	set_active(active_units)

func reset():
	active_units=0
	set_active(active_units)
