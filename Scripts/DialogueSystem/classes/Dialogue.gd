class_name Dialogue

extends Resource

enum Priority { STORY = 0, RELEVANT = 1, QUIP = 99}

export var id: String
export (Priority) var priority
export var bubble: bool


func _init(p_id = "", p_priority = Priority.QUIP, p_bubble = false):
	id = p_id;
	priority = p_priority;
	bubble = p_bubble

