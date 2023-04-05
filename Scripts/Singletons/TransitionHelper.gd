# Author: Marcus

extends Node

var _transition_timer: float = 0
var _transition_target: Node = null
var _transition_phase = 0
var _long_load: bool = false
var _is_transitioning: bool = false
var _fade_time: float = 0.25

const ZOOM_OUT = 4


func _process(delta):
	if not self._is_transitioning:
		return
	self._transition_timer += delta

	# intial zoom out
	var interp = MathUtils.interpolate(
		MathUtils.normalize_range(self._transition_timer, 0, self._fade_time),
		0,
		1,
		MathUtils.INTERPOLATE_IN_EXPONENTIAL
	)

	if self._transition_phase == 0:
		Scene.ui_layer.get_node("TransitionUI/FadeRect").modulate.a = interp
		CameraSingleton.set_zoom(Vector2.ONE * (interp + 0.25) * ZOOM_OUT, self)

		if self._transition_timer > self._fade_time:
			self._transition_timer = 0
			if not self._long_load:
				PausingSingleton.unpause(self)
				Scene.switch(self._transition_target)
				CameraSingleton.set_target_center(
					Scene.player.global_position * MathUtils.TO_ISO, self
				)
				CameraSingleton.jump_field(CameraSingleton.TARGET.LOCATION, self)
				CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM, self)
				self._transition_phase = 2
			else:
				self._transition_phase = 1

	elif self._transition_phase == 1:
		Scene.ui_layer.get_node("TransitionUI/LoadingText").modulate.a = interp

		if self._transition_timer > self._fade_time:
			PausingSingleton.unpause(self)
			Scene.switch(self._transition_target)
			self._transition_timer = 0
			self._transition_phase = 2
			CameraSingleton.set_target_center(Scene.player.global_position * MathUtils.TO_ISO, self)
			CameraSingleton.jump_field(CameraSingleton.TARGET.LOCATION, self)
			CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM, self)

	elif self._transition_phase == 2:
		Scene.ui_layer.get_node("TransitionUI/LoadingText").modulate.a = 0
		Scene.ui_layer.get_node("TransitionUI/FadeRect").modulate.a = 1 - interp
		CameraSingleton.set_zoom(Vector2.ONE * ((1 - interp) + 0.25) * ZOOM_OUT, self)

		if self._transition_timer > self._fade_time:
			CameraSingleton.remove_controller()
			self._is_transitioning = false


func transition(to_scene: Node, long_load: bool = false, fade_time: float = 0.5):
	if self._is_transitioning:
		return
	CameraSingleton.set_controller(self)
	PausingSingleton.pause(self)
	self._is_transitioning = true
	self._fade_time = fade_time
	self._long_load = long_load
	self._transition_target = to_scene
	self._transition_timer = 0
	self._transition_phase = 0
