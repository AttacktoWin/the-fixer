# Author: Marcus

class_name BaseEnemy extends LivingEntity

onready var anim_player: AnimationPlayer = $FlipComponents/Visual/AnimationPlayer
onready var visual: Node2D = $FlipComponents/Visual
onready var sprite_material: Material = null
onready var fsm: FSMController = $FSMController
onready var flip_components: Node2D = $FlipComponents

onready var idle_collider: Area2D = $IdleRadius
onready var nearby_entities: Area2D = $NearbyEntities

var disable_pathfind: int = 0

var _target: LivingEntity = null
var _last_known_target_location: Vector2 = Vector2(INF, INF)
var _investigate_target: Vector2 = Vector2(INF, INF)
var _current_path: PathfindResult = null
var _pathfind_timer: float = randf() * 30 + 30
var _current_attention: float = 0.0
const PATHFIND_INTERVAL = 60  # reevaluate the path every 60 frames

export(bool) var auto_pathfind: bool = true
export(bool) var has_melee_attack: bool = true
export(bool) var has_ranged_attack: bool = false
export(float) var melee_attack_range: float = 32
export(float) var ranged_attack_range: float = 400
export(float) var steering_factor: float = 0.5
export(float) var attention_time: float = 3  # after this amount of seconds, lose the target
export(float) var attention_radius: float = 1024
export(bool) var draw_path: bool = false

signal on_target_lost
signal on_target_set
signal on_investigate_target_set


# Called when the node enters the scene tree for the first time.
func _ready():
#	Wwise.register_listener(self)
#	Wwise.register_game_obj(self, name)
	if not "Enemy" in get_groups():
		print("WARN: enemy '", name, "' not in group 'Enemy'")
	var spr = visual.get_node("Sprite")
	spr.set_material(spr.get_material().duplicate())
	self.sprite_material = ($FlipComponents/Visual/Sprite).material


func set_nav_path(path: PathfindResult):
	self._current_path = path


func has_nav_path() -> bool:
	return self._current_path != null


func get_nav_path() -> PathfindResult:
	return self._current_path


func steer_from_walls() -> Vector2:
	return Pathfinder.get_vector_from_walls(self.global_position)


func apply_steering(in_vec: Vector2) -> Vector2:
	var steer = Vector2()
	for target in self.nearby_entities.get_overlapping_bodies():
		if target is get_script():
			var off = self.global_position - target.global_position
			var dist = off.length() / 512
			steer += (
				off.normalized()
				* MathUtils.interpolate(dist, 1, 0, MathUtils.INTERPOLATE_OUT)
			)
	steer += steer_from_walls()
	if not steer:
		return in_vec
	if steer.length_squared() > 1:
		steer = steer.normalized()
	return (in_vec + steer * self.steering_factor).normalized()


func _handle_pathfinding(delta):
	if self._current_path:
		self._current_path.update(self.global_position)
	if self.has_target():
		if (
			AI.has_LOS(self.global_position, self._target.global_position)
			and (
				(self.global_position - self._target.global_position).length()
				< self.attention_radius
			)
		):
			self._current_attention = 0
			self._last_known_target_location = self._target.global_position
		else:
			self._current_attention += delta

		if self._current_attention > self.attention_time:
			self.clear_target(true)

	if not self.auto_pathfind or not self._target or self.disable_pathfind:
		return
	self._pathfind_timer -= MathUtils.delta_frames(delta)
	if self._pathfind_timer < 0:
		self._pathfind_timer = PATHFIND_INTERVAL
		set_nav_path(
			Pathfinder.generate_path(self.global_position, self._last_known_target_location)
		)


func get_wanted_direction() -> Vector2:
	var vec = null
	if self._current_path:
		vec = self._current_path.get_target_vector()
	if self._target and AI.has_LOS(self.global_position, self._target.global_position):
		vec = Vector2(self._target.global_position - self.global_position).normalized()

	if vec:
		return apply_steering(vec)

	return Vector2()


func set_target(node: LivingEntity):
	if is_instance_valid(node):
		self.clear_target(false)
		self._target = node
		self._current_attention = 0
		emit_signal("on_target_set", node)
	else:
		print("WARN: Attempting to set invalid instance as target of node")


func clear_target(emit: bool):
	self._target = null
	self._current_path = null
	if emit:
		emit_signal("on_target_lost")


func has_target():
	self._check_target_available()
	return self._target != null


func get_target():
	self._check_target_available()
	return self._target


func _check_target_available():
	if not self._target:
		return
	if not is_instance_valid(self._target) or self._target.is_dead():
		self.clear_target(true)


func _process(_delta):
	self._check_target_available()
	if self.draw_path:
		update()
	._process(_delta)


func _physics_process(delta):
	self._check_target_available()
	self._handle_pathfinding(delta)
	._physics_process(delta)


func set_investigate_target(target: Vector2):
	self._investigate_target = target
	emit_signal("on_investigate_target_set", target)


func has_investigate_target():
	return self._investigate_target.x != INF


func clear_investigate_target():
	self._investigate_target = Vector2(INF, INF)


func get_investigate_target():
	if not has_investigate_target():
		return null
	return self._investigate_target


func alert(target: LivingEntity):
	if self._target:
		return
	self.set_target(target)


func _on_take_damage(_amount: float, _meta: HitMetadata):
	self.fsm.set_state(EnemyState.PAIN)
	self.setv(
		LivingEntity.VARIABLE.VELOCITY,
		(
			_meta.direction
			* _amount
			* 5
			* self.getv(LivingEntity.VARIABLE.KNOCKBACK_FACTOR)
			/ self.getv(LivingEntity.VARIABLE.WEIGHT)
		)
	)
	var bar = self.get_node("ProgressBar")
	bar.value = ((self.getv(LivingEntity.VARIABLE.HEALTH) / self.base_health) * 100)


func _draw():
	if self.has_nav_path():
		var path = self.get_nav_path()
		path.draw(self)


func _on_death():
	self.fsm.set_state(EnemyState.DEAD)
	self.queue_free()
