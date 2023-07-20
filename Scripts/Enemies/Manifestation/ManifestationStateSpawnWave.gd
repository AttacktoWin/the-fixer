# Author: Marcus

class_name ManifestationStateSpawnWave extends FSMNode

var _timer = 0
var _global_timer = 0
var _spawn_delay = 0.36
var _spawn_count = 5
var _current_spawn = 0

var _roar_fx = null

const ATTACK_DELAY = 0.7


func initialize():
	self._roar_fx = Scene.ui.get_node("RoarVFX")


func get_handled_states():
	return [ManifestationState.SPAWNING_WAVE]


func enter():
	self._timer = -0.5
	self._global_timer = 0
	self._current_spawn = 0
	Wwise.post_event_id(AK.EVENTS.ROAR_MANIFESTATION, Scene)
	self.fsm.set_animation("ROAR")
	CameraSingleton.shake(50)


func on_anim_reached_end(_anim: String):
	if _anim == "ROAR":
		self.fsm.set_animation("IDLE")


func _physics_process(delta):
	self._timer += delta
	self._global_timer += delta

	self._roar_fx.modulate.a = MathUtils.interpolate(
		abs(self._global_timer - 1), 0.4, 0, MathUtils.INTERPOLATE_IN_EXPONENTIAL
	)

	if self._timer > _spawn_delay:
		self.entity._spawn_random_enemies(1, false)
		self._timer -= self._spawn_delay
		self._current_spawn += 1

	if self._current_spawn >= self._spawn_count:
		self.fsm.set_state(ManifestationState.IDLE)


func exit():
	self._roar_fx.modulate.a = 0
