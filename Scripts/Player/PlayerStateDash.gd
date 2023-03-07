# Author: Marcus

class_name PlayerStateDash extends FSMNode

var _dash_timer = Timer.new()
var _dash_direction = Vector2()


func _init():
	self._dash_timer.one_shot = true
	self._dash_timer.connect("timeout", self, "_dash_increment")


func _ready():
	add_child(self._dash_timer)


# returns an array of states this entry claims to handle. This can be any data type
func get_handled_states():
	return [PlayerState.DASHING]


func enter():
	# Wwise.post_event_id(AK.EVENTS.DASH_PLAYER, self)
	self.fsm.set_animation("DASH")
	self.entity.setv(LivingEntity.VARIABLE.VELOCITY, Vector2())
	CameraSingleton.set_zoom(Vector2(1.01, 1.01))
	self._dash_direction = MathUtils.scale_vector_to_iso(
		CameraSingleton.get_mouse_from_camera_center().normalized()
	)

	self._dash_timer.wait_time = 0.25
	self._dash_timer.start()


func _dash_increment():
	CameraSingleton.set_zoom(Vector2(0.97, 0.97))
	CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM)
	CameraSingleton.set_zoom(Vector2(1, 1))
	self.entity.move_and_collide(self._dash_direction * 240)


func on_anim_reached_end():
	self.fsm.set_state(PlayerState.IDLE)


func exit():
	self._dash_timer.stop()  # interrupt


func _physics_process(_delta):
	pass


func _process(_delta):
	pass
