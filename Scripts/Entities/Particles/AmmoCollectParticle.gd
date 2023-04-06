extends Node2D

var _target: Node2D = null
var _target_location: Vector2 = Vector2.ZERO

var _timer = 0
var _velocity = Vector2(rand_range(-8, 8), rand_range(-10, -20))

var _target_angle = PI * 2 + rand_range(-PI / 4, PI / 4)

var target_y_offset =  -80

const WAIT_TIME = 0.8
const MAX_SPEED = 300.0
const ACCEL = 12.0


# Called when the node enters the scene tree for the first time.
func _ready():
	self._target_location = self.global_position
	self.z_index = 1


func set_target(target: Node2D):
	self._target = target


func _physics_process(delta):
	self._timer += delta
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
		self.global_position = self._target_location
		self.queue_free()
