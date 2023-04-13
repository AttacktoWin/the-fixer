extends Node2D

var _target: Node2D = null
var _target_location: Vector2 = Vector2.ZERO

var _bounce: bool = false
var _step = 0

var _timer = 0
var _velocity = Vector2(rand_range(-8, 8), rand_range(-10, -20))

var _target_angle = PI * 2 + rand_range(-PI / 4, PI / 4)

var _rand_rotate = rand_range(PI * 6, PI * 12)

var target_y_offset = -80

var collect_sound = AK.EVENTS.AMMO_PICKUP_PLAYER
var bounce_sound = null

const WAIT_TIME = 0.8
const MAX_SPEED = 300.0
const ACCEL = 12.0

signal on_reached_target


# Called when the node enters the scene tree for the first time.
func _ready():
	Wwise.register_game_obj(self, name)
	self._target_location = self.global_position
	self.z_index = 1


func set_target(target: Node2D):
	self._target = target


func set_bounce(bounce: bool):
	self._bounce = bounce


func _do_bounce(delta):
	self._velocity += Vector2(0, 20 * delta)
	self.position += self._velocity
	self.rotation += self._rand_rotate * sign(self._velocity.x) * delta
	self._rand_rotate *= 0.97
	if self._timer > 0.5:
		self.modulate.a = MathUtils.interpolate(self._timer - 0.5, 1, 0, MathUtils.INTERPOLATE_OUT)
	if self._timer > 1.5:
		self.queue_free()


func _physics_process(delta):
	self._timer += delta

	if self._step == 1:
		_do_bounce(delta)
		return

	self.position += self._velocity
	if self._timer < WAIT_TIME:
		self._velocity *= pow(0.92, MathUtils.delta_frames(delta))
		self.rotation = MathUtils.interpolate(
			self._timer / WAIT_TIME, 0, self._target_angle, MathUtils.INTERPOLATE_OUT_EXPONENTIAL
		)
		var v = 1.0
		if fmod(self._timer, 0.1) < 0.05:
			v = 0.5
		self.modulate.a = v
		return

	# get some values
	self.modulate.a = 1.0
	self.rotation = fmod(self.rotation, PI * 2)

	if is_instance_valid(self._target):
		self._target_location = self._target.global_position + Vector2(0, self.target_y_offset)

	var dir = MathUtils.to_iso(self._target_location - self.global_position).normalized()
	var move = dir * ACCEL * MathUtils.normalize_range(self._timer, WAIT_TIME, 1.5)

	# update velocity
	self._velocity += move
	var angle = self._velocity.angle()
	angle += (
		MathUtils.angle_difference(
			MathUtils.to_iso(self._target_location - self.global_position).angle(), angle
		)
		* 0.95
	)
	var length = self._velocity.length()
	self._velocity = Vector2(cos(angle) * length, sin(angle) * length)

	# update direction
	self.rotation += MathUtils.angle_difference(angle, self.rotation) * 0.05

	# are we there yet?
	if (
		(self._target_location - self.global_position).length_squared()
		< self._velocity.length_squared()
	):
		emit_signal("on_reached_target", self, self._bounce)
		if not self._bounce:
			if self.collect_sound:
				Wwise.post_event_id(self.collect_sound, self)
			self.global_position = self._target_location
			self.queue_free()
		else:
			if self.bounce_sound:
				Wwise.post_event_id(self.bounce_sound, self)
			self._timer = 0
			self._velocity = -self._velocity / 18
			self._velocity.y = -6
			self._velocity.x += rand_range(2, 4) * sign(self._velocity.x)
			self._step = 1


func get_angle():
	return atan2(self._velocity.y, self._velocity.x)
