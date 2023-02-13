class_name Dialogue

extends Resource

enum Priority { STORY = 1, QUIP = 99}

export var id: String
export (Priority) var priority


func _init(p_id = "", p_priority = Priority.QUIP):
	id = p_id;
	priority = p_priority;

