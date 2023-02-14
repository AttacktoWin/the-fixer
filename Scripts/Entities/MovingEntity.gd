class_name MovingEntity extends KinematicBody2D

# this script implements the basics of status effects and state

enum STATUSES { INVULNERABLE, SLOWED }
enum VARIABLE { MAX_SPEED, ACCEL, HEALTH, VELOCITY, DRAG, KNOCKBACK_FACTOR, WEIGHT }
export var base_speed = 340
export var base_health = 100
export var base_accel = 80
export var base_drag = 0.5
var variables = VariableList.new(
	VARIABLE,
	{
		VARIABLE.MAX_SPEED: base_speed,
		VARIABLE.HEALTH: base_health,
		VARIABLE.ACCEL: base_accel,
		VARIABLE.VELOCITY: Vector2(),
		VARIABLE.DRAG: base_drag,
		VARIABLE.KNOCKBACK_FACTOR: 0,
		VARIABLE.WEIGHT: 0
	}
)


func _init():
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
