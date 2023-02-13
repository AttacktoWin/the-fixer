class_name MovingEntity extends KinematicBody2D

# this script implements the basics of status effects and state

enum STATE {IDLE, MOVING, DASHING, HITSTUN, FIRING, RELOADING};
enum STATUSES {INVULNERABLE, SLOWED}
enum VARIABLE {MAX_SPEED, ACCEL, HEALTH, VELOCITY, DRAG, KNOCKBACK_FACTOR, WEIGHT}
export var base_speed = 340;
export var base_health = 100;
export var base_accel = 80;
export var base_drag = 0.5;
var variables = VariableList.new(	VARIABLE, {VARIABLE.MAX_SPEED: base_speed, VARIABLE.HEALTH:base_health, 
										VARIABLE.ACCEL: base_accel, VARIABLE.VELOCITY: Vector2(), VARIABLE.DRAG: base_drag, 
										VARIABLE.KNOCKBACK_FACTOR: 0, VARIABLE.WEIGHT: 0})

var _state = STATE.IDLE
var _status_timers = {}

# how long you've been in the last state. can be useful for launching effects
var _state_frame_counter = 0;

var _state_timer = Timer.new()

func _init():
	pass

func state_is_interruptable(__state):
	return true

func set_state(new_state):
	if new_state == self._state or not state_is_interruptable(self._state):
		return false
	self._state_time_counter = 0
	self._state = new_state
	return true

func reset_state():
	self._state_time_counter = 0
	self._state = STATE.IDLE

func state_finished():
	pass

func _on_pause_change(should_pause, ignore_entity):
	if ignore_entity == self:
		return
	set_process(not should_pause)
	set_physics_process(not should_pause)

func _ready():
	# linter is mad at me
	var _error = null
	_error = PausingSingleton.connect("pause_changed", self, "_on_pause_change")
	if _error:
		print("Error connecting to pause: ", _error)
	
	self._state_timer.connect("timeout", self, "state_finished")
	add_child(self._state_timer)

func _set_state_timeout(timeout_seconds):
	self._state_timer.start(timeout_seconds)

func _process(_delta):
	self._state_frame_counter += 1

func _getv(variable):
	return self.variables.get_variable(variable)

func _setv(variable, v):
	self.variables.set_variable(variable, v)

# func _is_status_active(status):
# 	var s = self._status_timers.get(status)
# 	return s != null and s > 0

# func add_status(status, time):
# 	pass

func _try_move():
	# unlikely to ever change, but here anyway
	_setv(VARIABLE.VELOCITY, move_and_slide(_getv(VARIABLE.VELOCITY)))
