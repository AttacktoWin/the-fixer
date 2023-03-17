class_name Dialogue

extends Resource

enum Priority { SPECIFIC = 0, STORY = 1, RELEVANT = 2, QUIP = 99}

export var id: String
export (Priority) var priority
export var bubble: bool


func _init(p_id = "", p_priority = Priority.QUIP, p_bubble = false):
	id = p_id;
	priority = p_priority;
	bubble = p_bubble

