# Author: Marcus

class_name ManifestationStateIdle extends FSMNode

const MIN_DISTANCE = 256

const SPAWN_WAVE_TIMER = 3.0  # check every 4 seconds
var _timer: float = 2.0


func get_handled_states():
	return [ManifestationState.IDLE]


func enter():
	self.fsm.set_animation("IDLE")


func _physics_process(delta):
	self._timer += delta
	if (self.entity.global_position - Scene.player.global_position).length() < MIN_DISTANCE:
		self.fsm.set_state(ManifestationState.ATTACKING_MELEE)
	if self._timer > SPAWN_WAVE_TIMER:
		self._timer = 0
		if AI.get_all_enemies().size() == 0:
			self.fsm.set_state(ManifestationState.SPAWNING_WAVE)
