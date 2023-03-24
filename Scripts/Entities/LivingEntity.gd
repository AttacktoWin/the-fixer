# Author: Marcus

class_name LivingEntity extends Entity

enum STATUSES { INVULNERABLE, SLOWED }
enum VARIABLE { MAX_SPEED, ACCEL, HEALTH, VELOCITY, DRAG, KNOCKBACK_FACTOR, WEIGHT }
export var base_speed: float = 340
export var base_health: float = 100
export var base_accel: float = 80
export var base_drag: float = 1.025
onready var variables = VariableList.new(
	VARIABLE,
	{
		VARIABLE.MAX_SPEED: base_speed,
		VARIABLE.HEALTH: base_health,
		VARIABLE.ACCEL: base_accel,
		VARIABLE.VELOCITY: Vector2(),
		VARIABLE.DRAG: base_drag,
		VARIABLE.KNOCKBACK_FACTOR: 1,
		VARIABLE.WEIGHT: 1
	}
)

export var entity_radius: float = 32
export var push_amount: float = 256
export(NodePath) var entity_collider_path = NodePath("EntityCollider")

var disable_pushing: int = 0

var _entity_collider = null

var _is_dead = false


func _get_node_or_err(test_path, default_path):
	var node = null
	if test_path:
		node = get_node_or_null(test_path)
	if not node and default_path:
		node = get_node_or_null(default_path)

	if not node:
		print("WARN: required node for '", default_path, "' not found in entity '", self.name, "'!")
	return node


func _on_pause_change(should_pause, ignore_entity):
	if ignore_entity == self:
		return
	set_process(not should_pause)
	set_physics_process(not should_pause)


func _ready():
	self._entity_collider = self._get_node_or_err(entity_collider_path, "EntityCollider")
	# linter is mad at me
	var _error = null
	_error = PausingSingleton.connect("pause_changed", self, "_on_pause_change")
	if _error:
		print("Error connecting to pause: ", _error)


func getv(variable):
	return self.variables.get_variable(variable)


func setv(variable, v):
	self.variables.set_variable(variable, v)


func get_wanted_velocity(dir_vector: Vector2) -> Vector2:
	return dir_vector * getv(VARIABLE.MAX_SPEED)


func _try_move():
	# warning-ignore:return_value_discarded
	move_and_slide(getv(VARIABLE.VELOCITY))


func _physics_process(delta):
	var push_dir = Vector2()
	if not self.disable_pushing:
		var colliding = CollisionUtils.get_overlapping_bodies_filtered(
			self._entity_collider, self, KinematicBody2D
		)
		for other in colliding:
			var v = self.global_position - other.global_position
			var dist = v.length()
			var max_dist = self.entity_radius + other.entity_radius
			if dist > max_dist:
				dist = max_dist

			var interp = MathUtils.interpolate(
				dist / max_dist, self.push_amount, 0, MathUtils.INTERPOLATE_OUT
			)

			push_dir += v.normalized() * interp
	# warning-ignore:return_value_discarded
	self.move_and_slide(push_dir * MathUtils.delta_frames(delta))


func is_dead():
	return self._is_dead


func _on_death():
	print("Rip")


func _check_death() -> bool:
	if self.getv(VARIABLE.HEALTH) <= 0 and not self._is_dead:
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
	self.setv(VARIABLE.HEALTH, self.getv(VARIABLE.HEALTH) - amount)
	self._on_take_damage(amount, meta)
	# warning-ignore:return_value_discarded
	self._check_death()
