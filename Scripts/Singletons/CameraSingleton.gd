# Author: Marcus

extends Node

var _shake_timer = 0
var _location_target = Vector2()
var _zoom_target = Vector2(2, 4)
var _transition_factor = 0.1
var _viewport
var _camera

const SHAKE_FACTOR = 10
const MAX_SHAKE_TIMER = 120


enum TARGET { LOCATION, ZOOM, ROTATION }
var _frozen_dict = {}


func _init():
	for key in TARGET:
		self._frozen_dict[TARGET[key]] = false


func set_camera(camera):
	self._camera = camera
	self._camera.zoom *= MathUtils.FROM_ISO
	self._viewport = camera.get_viewport()


func set_target_center(target):
	self._location_target.x = target.x
	self._location_target.y = target.y


func set_transition_factor(transition_factor):
	self._transition_factor = transition_factor


func shake(shake_timer):
	self._shake_timer = min(self._shake_timer + shake_timer, MAX_SHAKE_TIMER)


func shake_max(value):
	self._shake_timer = max(self._shake_timer, value)


func get_local_mouse() -> Vector2:
	return self._viewport.get_mouse_position()


func get_absolute_mouse() -> Vector2:
	return self._camera.get_global_mouse_position()


func get_absolute_mouse_iso() -> Vector2:
	return self._camera.get_global_mouse_position() * MathUtils.TO_ISO


func get_mouse_from_camera_center() -> Vector2:
	return self.get_local_mouse() - self._viewport.size / 2


func get_mouse_from_camera_center_screen() -> Vector2:
	return get_mouse_from_camera_center() * MathUtils.FROM_ISO


func set_zoom(new_scale):
	self._zoom_target = new_scale * MathUtils.FROM_ISO


func jump_field(target_type):
	match target_type:
		TARGET.LOCATION:
			self._camera.transform.origin = self._location_target
		TARGET.ZOOM:
			self._camera.zoom = self._zoom_target


# prevents the camera from moving
func freeze(type):
	self._frozen_dict[type] = true


func unfreeze(type):
	self._frozen_dict[type] = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not self._camera:
		return
	var delta_60 = _delta * 60
	self._shake_timer = max(self._shake_timer / 1.2 / delta_60, 0)

	# move
	if not self._frozen_dict[TARGET.LOCATION]:
		self._camera.transform.origin = (
			self._camera.transform.origin
			+ (
				(self._location_target - self._camera.transform.origin)
				* pow(self._transition_factor, 1 / delta_60)
			)
		)

	# zoom
	if not self._frozen_dict[TARGET.ZOOM]:
		self._camera.zoom = (
			self._camera.zoom
			+ (self._zoom_target - self._camera.zoom) * pow(self._transition_factor, 1 / delta_60)
		)

	# SCREEN SHAKE!!! (the most important part)
	self._camera.transform.origin = (
		self._camera.transform.origin
		+ (
			Vector2(
				rand_range(-self._shake_timer, self._shake_timer),
				rand_range(-self._shake_timer, self._shake_timer)
			)
			/ 2
		)
	)
