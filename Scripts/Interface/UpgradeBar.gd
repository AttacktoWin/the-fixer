extends Node

enum STAT {HEALTH,SPEED,MELEE,RANGED}
export(STAT) var stat

var bar_units = []
var active_units = 0

func _ready():
	bar_units = get_children()
	set_active(StatsSingleton.stats[stat])

func set_active(count)->bool:
	if count>bar_units.size():
		return false
	for i in count:
		bar_units[i].frame = 1
	return true

func increment():
	StatsSingleton.increment(stat)
	set_active(StatsSingleton.stats[stat])

func refresh():
	for i in bar_units.size():
		bar_units[i].frame = 0
	set_active(StatsSingleton.stats[stat])
