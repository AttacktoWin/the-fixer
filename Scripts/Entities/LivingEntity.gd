class_name LivingEntity extends KinematicBody2D

# this script implements the basics of status effects and state

enum STATUSES { INVULNERABLE, SLOWED }
enum VARIABLE { MAX_SPEED, ACCEL, HEALTH, VELOCITY, DRAG, KNOCKBACK_FACTOR, WEIGHT }
export var base_speed: float = 340
export var base_health: float = 100
export var base_accel: float = 80
export var base_drag: float = 0.5
onready var variables = VariableList.new(
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

var _is_dead = false


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


func _try_move():
	# unlikely to ever change, but here anyway
	_setv(VARIABLE.VELOCITY, move_and_slide(_getv(VARIABLE.VELOCITY)))


func is_dead():
	return self._is_dead


func _on_death():
	print("Rip")


func _check_death() -> bool:
	if self._getv(VARIABLE.HEALTH) <= 0 and not self._is_dead:
		self._is_dead = true
		# queue_free()
		self._on_death()  # emit signal
		return true
	return false


# warning-ignore:unused_argument
func can_be_hit():
	return true


func try_take_damage(amount, meta) -> bool:
	# check status... if status == invulenrable: return false

	self._take_damage(amount, meta)
	return true


func _on_take_damage(_amount: float, _meta: HitMetadata):
	pass


func _take_damage(amount, meta):
	self._setv(VARIABLE.HEALTH, self._getv(VARIABLE.HEALTH) - amount)
	self._on_take_damage(amount, meta)
	# warning-ignore:return_value_discarded
	self._check_death()
