class_name Base_FSM extends Node2D

export(NodePath) var initial_state_path

onready var p_state: Base_State = get_node(initial_state_path)

var context := {}


func _ready() -> void:
	yield(owner, "ready")
	for child in get_children():
		if child.has_method("tick"):
			child.state_machine = self
	p_state.enter()


func _unhandled_input(event: InputEvent) -> void:
	p_state.handle_input(event)


func _process(delta: float) -> void:
	# print(p_state)
	p_state.tick(delta)


func _physics_process(delta: float) -> void:
	p_state.physics_tick(delta)


func transition_to(target_state_name: String, _msg: Dictionary = {}):
	if not has_node(target_state_name):
		return

	p_state.exit()
	context["prev"] = (p_state.name)
	print("recived")
	yield(p_state, "ready_to_transition")
	p_state = get_node(target_state_name)
	p_state.enter()
