# Author: Marcus

class_name EnemyStateHurt extends FSMNode

const HURT_DURATION = 0.2  # TODO: make not hard coded
const FLASH_RATE = 0.1

var _timer = 0


func get_handled_states():
	return [EnemyState.PAIN]


func enter():
	self._timer = 0
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, true)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_LINE_COLOR, Constants.COLOR.RED)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_FLASH_COLOR, Constants.COLOR.WHITE)
	self.fsm.set_animation("IDLE")


func _process(delta):
	self._timer += delta
	var frac = fmod(self._timer, FLASH_RATE) / FLASH_RATE
	var color = MathUtils.interpolate_color(
		frac * 2, Constants.COLOR.WHITE, Constants.COLOR.RED, MathUtils.INTERPOLATE_SMOOTH
	)
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, frac < 0.5)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_FLASH_COLOR, color)

	if self._timer > HURT_DURATION:
		if self.entity.has_target():
			self.fsm.set_state(EnemyState.CHASING)
		else:
			self.fsm.set_state(EnemyState.IDLE)


func _physics_process(_delta):
	var current_vel = self.entity.getv(LivingEntity.VARIABLE.VELOCITY)
	self.entity.setv(
		LivingEntity.VARIABLE.VELOCITY, current_vel / self.entity.getv(LivingEntity.VARIABLE.DRAG)
	)
	self.entity._try_move()


func exit():
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, false)
	self.entity.sprite_material.set_shader_param(
		Constants.SP.C_LINE_COLOR, Constants.COLOR.INVISIBLE
	)
