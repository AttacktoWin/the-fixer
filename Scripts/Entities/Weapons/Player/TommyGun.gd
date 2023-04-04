# Author: Marcus

class_name PlayerGunTommy extends PlayerBaseGun

export var fire_count: int = 3
export var fire_repeat_speed: float = 0.05
export var gun_pierce_override: int = 2

var _fire_counter = 0
var _fire_repeat_timer = 0


func _fire_impl(direction: float):
	var bullet: BulletBase = _generate_bullet()
	bullet.set_direction(direction + rand_range(-bullet_spread, bullet_spread))
	bullet.max_pierce = self.gun_pierce_override
	CameraSingleton.shake(self.screen_shake_on_fire)
	AI.notify_sound(self.global_position)


func _cooldown_timer_tick(delta):
	if self._fire_counter > 0:
		self._fire_repeat_timer -= delta
		if self._fire_repeat_timer < 0:
			self._fire_repeat_timer += fire_repeat_speed
			self._fire_counter -= 1

			Wwise.post_event_id(self.sound_fire, self.entity)
			self._fire_impl(_get_fire_angle())
	else:
		._cooldown_timer_tick(delta)


func _fire(direction: float, _target: Node2D = null):
	self._fire_counter = fire_count - 1
	self._fire_repeat_timer = fire_repeat_speed
	self._fire_impl(direction)
