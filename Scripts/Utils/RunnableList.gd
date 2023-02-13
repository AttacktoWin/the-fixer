class_name RunnableList extends Node2D

var _runnables = {}
var _counter = 0


class PrioritySort:
	static func sort(a, b):
		if a.priority == b.priority:
			return a.index < b.index
		return a.priority < b.priority


class SortableRunnable:
	var runnable
	var priority
	var index
	var name

	func _init(runnable_arg, priority_arg: int, index_arg: int, name_arg: String):
		self.runnable = runnable_arg
		self.priority = priority_arg
		self.index = index_arg
		self.name = name_arg


func _init(choices: Dictionary):
	if not choices:
		push_error("No choices supplied!")

	for key in choices:
		var value = choices[key]
		self._runnables[value] = []


func _check_choice_or_throw(choice):
	assert(has_choice(choice))


func has_choice(choice) -> bool:
	return choice in self._runnables


func _get_runnables(choice) -> Array:
	var values = []
	for x in self._runnables[choice]:
		values.push_back(x.runnable)
	return values


func _get_runnables_raw(choice) -> Array:
	return self._runnables[choice]


func add_runnable(choice: int, runnable, priority: int, _name: String = "!NO_NAME"):
	self._check_choice_or_throw(choice)

	var l = SortableRunnable.new(runnable, priority, self._counter, _name)
	self._counter += 1

	self._get_runnables_raw(choice).push_back(l)
	self._recalculate_priorities(_get_runnables_raw(choice))


# finds and removes the decorator either by reference or by name
func remove_runnable(choice: int, runnable_or_name):
	self._check_choice_or_throw(choice)
	var runnables = _get_runnables_raw(choice)

	for x in range(len(runnables)):
		var l = runnables[x]
		if l.name == runnable_or_name or l.runnable == runnable_or_name:
			runnables.pop_at(x)
			return


func _recalculate_priorities(arr):
	arr.sort_custom(PrioritySort, "sort")


func _process(delta):
	for key in self._runnables:
		var list = self._runnables[key]
		for sortable_runnable in list:
			sortable_runnable.runnable.tick(delta)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.
