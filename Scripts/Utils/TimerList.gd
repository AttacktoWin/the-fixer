# Author: Marcus

class_name TimerList extends Node2D

var _entity = null
var _timers = {}
var _max_values = {}


func _init(entity, choices: Dictionary, max_values: Dictionary = {}):
	self._entity = entity

	if not choices:
		print("ERR: No choices supplied to TimerList")

	for key in choices:
		var value = choices[key]
		self._timers[value] = 0

	for key in max_values:
		if not key in self._timers:
			print("WARN: max value set for nonexistent timer: '", key, "'")
		self._max_values[key] = max_values[key]


func _check_choice_or_throw(choice):
	assert(has_choice(choice))


func has_choice(choice) -> bool:
	return choice in self._timers


func get_percentage_max(variable) -> float:
	var max_value = self._max_values.get(variable, 1)
	return self.get_timer(variable) / max_value


func get_timer(variable):
	self._check_choice_or_throw(variable)
	return self._timers[variable]


func set_timer(variable, value):
	var max_value = self._max_values.get(variable, INF)
	self._timers[variable] = clamp(value, 0, max_value)


func delta_timer(variable, value):
	var max_value = self._max_values.get(variable, INF)
	self._timers[variable] = clamp(self._timers[variable] + value, 0, max_value)


func _physics_process(delta):
	for key in self._timers:
		self._timers[key] = clamp(self._timers[key] - delta, 0, INF)
