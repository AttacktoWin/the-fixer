extends Node

var _shake_timer = 0
var _target = Vector2()
var _current = Vector2()
var _transition_factor = 0.2
var _viewport

const SHAKE_FACTOR = 10
const MAX_SHAKE_TIMER = 120


# Called when the node enters the scene tree for the first time.
func _ready():
	self._viewport = get_viewport()


func set_target(target):
	self._target.x = target.x
	self._target.y = target.y


func set_target_center(target):
	self._target.x = target.x - self._viewport.size.x / 2
	self._target.y = target.y - self._viewport.size.y / 2


func set_transition_factor(transition_factor):
	self._transition_factor = transition_factor


func shake(shake_timer):
	self._shake_timer = min(self._shake_timer + shake_timer, MAX_SHAKE_TIMER)


func shake_max(value):
	self._shake_timer = max(self._shake_timer, value)


func get_local_mouse() -> Vector2:
	return self._viewport.get_mouse_position()


func get_absolute_mouse() -> Vector2:
	return self.get_local_mouse() + self._current


func get_mouse_from_camera_center() -> Vector2:
	return self.get_local_mouse() - self._viewport.size / 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	self._current = self._current + (self._target - self._current) * self._transition_factor
	self._shake_timer = max(self._shake_timer / 3, 0)
	# move the camera!

	# print(self._target.x, "::", self._target.y, " actual: ", self._current.x, "::", self._current.y)

	self._viewport.canvas_transform.origin = (
		-self._current
		+ (
			Vector2(
				rand_range(-self._shake_timer, self._shake_timer),
				rand_range(-self._shake_timer, self._shake_timer)
			)
			/ 2
		)
	)
