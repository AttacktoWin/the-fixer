# Author: Marcus

class_name ManifestationStateSpawnWave extends FSMNode

var _timer = 0
var _spawn_delay = 0.36
var _spawn_count = 5
var _current_spawn = 0

const ATTACK_DELAY = 0.7


func get_handled_states():
	return [ManifestationState.SPAWNING_WAVE]


func enter():
	self._timer = -0.5
	self._current_spawn = 0
	self.fsm.set_animation("ROAR")
	CameraSingleton.shake(50)


func on_anim_reached_end(_anim: String):
	if _anim == "ROAR":
		self.fsm.set_animation("IDLE")


func _physics_process(delta):
	self._timer += delta
	if self._timer > _spawn_delay:
		CameraSingleton.shake(30)
		self.entity._spawn_random_enemies(1, false)
		self._timer -= self._spawn_delay
		self._current_spawn += 1

	if self._current_spawn >= self._spawn_count:
		self.fsm.set_state(ManifestationState.IDLE)
