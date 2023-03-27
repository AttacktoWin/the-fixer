# Author: Marcus

class_name PlayerStateDash extends FSMNode

var _dash_timer = Timer.new()
var _dash_direction = Vector2()
var _gun_angle = -1
var _gun_counter = 0
const DASH_GUN_ANGLE = 0.8


func _init():
	self._dash_timer.one_shot = true
	self._dash_timer.connect("timeout", self, "_dash_increment")


func _ready():
	add_child(self._dash_timer)


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.DASHING]


func enter():
	self._gun_angle = MathUtils.abs_x(self.entity.get_wanted_gun_vector()).angle()
	self._gun_counter = 0
	# Wwise.post_event_id(AK.EVENTS.DASH_PLAYER, self)
	self.fsm.set_animation("DASH")
	self.entity.setv(LivingEntityVariable.VELOCITY, Vector2())
	CameraSingleton.set_zoom(Vector2(1.01, 1.01))
	self._dash_direction = CameraSingleton.get_mouse_from_camera_center_screen().normalized()

	self._dash_timer.wait_time = 0.25
	self._dash_timer.start()


func _dash_increment():
	CameraSingleton.set_zoom(Vector2(0.97, 0.97))
	CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM)
	CameraSingleton.set_zoom(Vector2(1, 1))
	self.entity.move_and_slide(self._dash_direction * 240 * 60)


func on_anim_reached_end():
	self.fsm.set_state(PlayerState.IDLE)


func exit():
	self._dash_timer.stop()  # interrupt


func _physics_process(_delta):
	pass


func _process(delta):
	self._gun_counter += delta
	var ang = 0
	if self._gun_counter > 0.3:
		ang = MathUtils.interpolate(
			(self._gun_counter - 0.3) * 10,
			DASH_GUN_ANGLE,
			MathUtils.abs_x(self.entity.get_wanted_gun_vector()).angle(),
			MathUtils.INTERPOLATE_IN
		)
	else:
		ang = MathUtils.interpolate(
			self._gun_counter * 10, self._gun_angle, DASH_GUN_ANGLE, MathUtils.INTERPOLATE_IN
		)
	self.entity.set_gun_angle(ang)
