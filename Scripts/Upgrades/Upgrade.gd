# Author: Marcus

class_name Upgrade extends Resource


func get_save_data() -> Dictionary:
	print("ERR: save name not implmemented!")
	return {"name": "", "priority": 0}


func get_upgrade_types() -> Array:
	return [UpgradeType.ENTITY]


func apply(_entity, _type: int):
	pass
