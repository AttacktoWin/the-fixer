# Author: Marcus

class_name Manifestation extends LivingEntity

onready var hitbox: BaseAttack = $HitBox

var _start_position = Vector2()

const HIT_SCENE = preload("res://Scenes/Particles/HitScene.tscn")


func get_display_name():
	return "Manifestation"


func _ready():
	self._start_position = self.global_position


func _enter_tree():
	CameraSingleton.set_controller(self)
	CameraSingleton.set_zoom(Vector2.ONE, self)
	CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM, self)


func _exit_tree():
	CameraSingleton.remove_controller(self)


func _physics_process(_delta):
	self.global_position = self._start_position
	_handle_camera()


func _handle_camera():
	var center = CameraSingleton.get_mouse_from_camera_center() / 360
	var off = (
		Vector2(
			MathUtils.interpolate(abs(center.x), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL),
			MathUtils.interpolate(abs(center.y), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL)
		)
		* Vector2(sign(center.x), sign(center.y))
	)
	var off2 = off + self.getv(LivingEntityVariable.VELOCITY) / 8
	CameraSingleton.set_target_center(
		MathUtils.to_iso(self.global_position * 4 + Scene.player.global_position) / 5 + off2, self
	)


func _on_take_damage(info: AttackInfo):
	var fx = HIT_SCENE.instance()
	var direction = info.get_attack_direction(self.global_position)
	fx.initialize(direction.angle(), info.damage)
	Scene.runtime.add_child(fx)
	if info.attack.damage_type == AttackVariable.DAMAGE_TYPE.RANGED:
		fx.global_position = info.attack.global_position
	else:
		fx.global_position = self.global_position
	._on_take_damage(info)
