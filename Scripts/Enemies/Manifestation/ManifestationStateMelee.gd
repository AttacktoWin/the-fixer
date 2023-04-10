# Author: Marcus

class_name ManifestationStateMelee extends FSMNode

var _timer = 0
var _attacked = false

const ATTACK_DELAY = 0.7


func get_handled_states():
	return [EnemyState.ATTACKING_MELEE]


func enter():
	self.fsm.set_animation("SLAM")
	self._timer = 0
	self._attacked = false


func on_anim_reached_end(_anim: String):
	self.fsm.set_state(EnemyState.IDLE)


func _physics_process(delta):
	self._timer += delta
	if self._timer > ATTACK_DELAY and not self._attacked:
		CameraSingleton.shake(60)
		self._attacked = true
		self.entity.hitbox.invoke_attack()
