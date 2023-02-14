class_name LivingEntity extends Base_FSM

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
	._ready()


func _getv(variable):
	return self.variables.get_variable(variable)


func _setv(variable, v):
	self.variables.set_variable(variable, v)


func _try_move():
	# unlikely to ever change, but here anyway
	_setv(VARIABLE.VELOCITY, move_and_slide(_getv(VARIABLE.VELOCITY) * Vector2(1, 0.69)))


func _on_death():
	print("Rip")


func _check_death() -> bool:
	if self._getv(VARIABLE.HEALTH) <= 0:
		queue_free()
		self._on_death()  # emit signal
		return true
	return false


func try_take_damage(amount) -> bool:
	# check status... if status == invulenrable: return false

	self._take_damage(amount)
	return true


func _take_damage(amount):
	self._setv(VARIABLE.HEALTH, self._getv(VARIABLE.HEALTH) - amount)
	# warning-ignore:return_value_discarded
	self._check_death()
