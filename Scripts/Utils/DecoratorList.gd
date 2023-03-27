class_name DecoratorList extends RunnableList


func _init(entity, choices: Dictionary).(entity, choices):
	pass


func invoke(event, _other_arg = null):
	for runnable in _get_runnables(event):
		runnable.run(_other_arg)
