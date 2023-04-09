# Author: Marcus

class_name EnemyStateDead extends FSMNode

export var animation_name: String = "ALERTED"
export(AK.EVENTS._dict) var alert_sound: int = -1


func get_handled_states():
	return [EnemyState.DEAD]


func enter():
	if self.entity.death_animation_player:
		self.entity.death_animation_player.play("EXPLODE")
		self.entity.death_animation_player.connect("animation_finished", self, "_on_anim_complete")


func _physics_process(delta):
	self.entity._try_move()
	self.entity.setv(
		LivingEntityVariable.VELOCITY,
		self.entity.getv(LivingEntityVariable.VELOCITY) * pow(0.9, MathUtils.delta_frames(delta))
	)


func _on_anim_complete(_anim: String):
	self.entity.queue_free()


func exit():
	pass
