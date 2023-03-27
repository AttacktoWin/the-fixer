class_name VariableList extends RunnableList

var _values = {}


func _init(entity, choices: Dictionary, _default = null).(entity, choices):
	if typeof(_default) == TYPE_DICTIONARY:
		for key in _default:
			var value = _default[key]
			self._values[key] = value
	else:
		for key in choices:
			var value = choices[key]
			self._values[value] = _default


func add_runnable(variable: int, runnable: Runnable, priority: int, _name: String = "!NO_NAME"):
	runnable.default_value = get_variable_raw(variable)
	.add_runnable(variable, runnable, priority, _name)


func get_variable(variable):
	var current = self._values[variable]
	for runnable in self._get_runnables(variable):
		current = runnable.run(current)
	return current


func set_variable(variable, value):
	self._values[variable] = value
	return value


func get_variable_raw(variable):
	return self._values[variable]
