class_name UnlockTableEntry

extends Resource

export var unlocked_ids: Array
export var removed_ids: Array

func _init(p_unlocked_ids = [], p_removed_ids = []):
	unlocked_ids = p_unlocked_ids;
	removed_ids = p_removed_ids;
