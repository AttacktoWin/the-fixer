# Author: Marcus

class_name FSMController extends Node2D

signal on_state_changed(prev_state, new_state)

export(NodePath) var root_state = null  # optional, take first child otherwise
export(NodePath) var animation_player = null  # optional, ignore anim callbacks otherwise
export(NodePath) var entity = null  # optional, take owner otherwise refers to the entity which owns this FSM (i.e. enemy, player, etc)

var _state_map = {}
var _alias_map = {}
var _current_state = null
var _current_state_name = null
var _transition_target = null
var _state_timer = 0
var _last_animation_timer = 0
var _state_index = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	self._current_state = get_node(root_state) if root_state else null
	self.entity = get_node(root_state) if entity else owner
	self._get_states_from_children()
	if self.animation_player:
		self.animation_player = get_node(self.animation_player)
		# warning-ignore:return_value_discarded
		# connect("animation_finished", self, "_on_animation_looped")

	if self._current_state:
		var arr = self._current_state.get_handled_states()
		if len(arr) > 0:
			self._current_state_name = arr[0]
		self._current_state.enter()


func _get_states_from_children():
	var first_child = null
	for child in self.get_children():
		if not (child is FSMNode):
			continue
		if not first_child:
			first_child = child
		self.add_state(child)

	if not root_state:
		self._current_state = first_child


func add_state(node: FSMNode):
	var idx = 0
	self._state_map[node.get_name()] = node
	for state_name in node.get_handled_states():
		self._state_map[state_name] = node
		self._alias_map[state_name] = idx
		idx += 1
	node.fsm = self
	node.entity = self.entity


func remove_state(node: FSMNode):
	if not node.fsm == self:
		print("ERR: cannot remove node which is not in this FSM")
		return

	for state_name in node.get_handled_states():
		self._state_map.erase(state_name)
		self._alias_map.erase(state_name)

	self.remove_child(node)


func _process(delta):
	self._state_timer += delta
	if not self._current_state:
		print("ERR: no state!")
		return
	self._current_state._process(delta)


func get_animation_player():
	return self.animation_player


func has_animation_player():
	return self.animation_player != null


func _set_animation_if_anim_player(name: String):
	if not self.has_animation_player():
		return
	if not self.animation_player.has_animation(name):
		print("ERR: animation player does not have animation ", name)
		return
	if self.animation_player.current_animation != name:
		self._last_animation_timer = 0
		self.animation_player.play(name)


func set_animation(name: String):
	self._set_animation_if_anim_player(name)


func _check_anim_loop(delta):
	if not self.has_animation_player():
		return
	var ap = self.animation_player
	var current = ap.current_animation_position
	var last = self._last_animation_timer

	if (
		sign(current - last) != sign(ap.playback_speed)
		or delta >= ap.current_animation_length
		or ap.current_animation_position == ap.current_animation_length
	):
		self._on_animation_looped()

	self._last_animation_timer = current


func _on_animation_looped():
	self._current_state.on_anim_reached_end()


func _transition(target: FSMNode, target_name):
	var prev = self._current_state
	if prev:
		prev.exit()
	self._state_timer = 0
	self._current_state = target
	self._current_state_name = target_name
	target.enter()
	var anim_target = target.get_animation_name()
	if anim_target:
		self._set_animation_if_anim_player(anim_target)
	emit_signal("on_state_changed", prev, target)
	self._transition_target = null


func _check_transition():
	if self._transition_target != null:
		self._transition(self._state_map[self._transition_target], self._transition_target)


func _physics_process(delta):
	if not self._current_state:
		print("ERR: no state!")
		return

	self._check_anim_loop(delta)
	self._check_transition()

	self._current_state._physics_process(delta)
	self._check_transition()


func current_state():
	return self._current_state


# if a single entry handles multiple states (bosses), this number will tell you which state is currently being played.
func state_index():
	return self._alias_index


func is_this_state(node: FSMNode):
	return self._current_state == node


func set_state(state_name, override: bool = false):
	if not self._state_map.has(state_name):
		print("ERR: unknown state ", state_name)
		return

	if not self._current_state:
		self._transition(self._state_map[state_name], self._transition_target)
		return

	# is something queued already?
	if self._transition_target != null and not override:
		return

	# is the state non interruptable?
	if not self._current_state.state_is_interruptable() and not override:
		return

	self._transition_target = state_name
