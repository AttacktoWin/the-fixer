# Author: Marcus

class_name BaseEnemy extends LivingEntity

onready var anim_player: AnimationPlayer = $FlipComponents/Visual/AnimationPlayer
onready var visual: Node2D = $FlipComponents/Visual
onready var sprite_material: Material = null
onready var fsm: FSMController = $FSMController
onready var flip_components: Node2D = $FlipComponents
onready var hitbox: Node2D = get_node_or_null("FlipComponents/HitBox")
onready var death_animation_player: AnimationPlayer = get_node_or_null(
	"VFX_Explosion/AnimationPlayer"
)

onready var idle_collider: Area2D = $IdleRadius
onready var nearby_entities: Area2D = $NearbyEntities

var disable_pathfind: int = 0

var _appear_range: float = 512

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
export(bool) var deaf: bool = false
export(bool) var draw_path: bool = false

const HIT_SCENE = preload("res://Scenes/Particles/HitScene.tscn")

const HEALTH_CHANCE_RANGED = 0.05
const HEALTH_CHANCE_MELEE = 0.1

signal on_target_lost
signal on_target_set
signal on_investigate_target_set


# Called when the node enters the scene tree for the first time.
func _ready():
	Wwise.register_listener(self)
	Wwise.register_game_obj(self, name)
	if not "Enemy" in get_groups():
		print("WARN: enemy '", name, "' not in group 'Enemy'")
	var spr = visual.get_node("Sprite")
	spr.set_material(spr.get_material().duplicate())
	self.sprite_material = ($FlipComponents/Visual/Sprite).material
	self._appear_range = Scene.level_node.enemy_appear_distance if Scene.level_node else 1024.0
	Scene.connect("world_updated", self, "_world_updated")  # warning-ignore:return_value_discarded


func _world_updated():
	self._appear_range = Scene.level_node.enemy_appear_distance


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


func get_steered_direction(to_location: Vector2):
	return apply_steering((to_location - self.global_position).normalized())


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


func _physics_process(delta):
	if is_nan(self.position.x) or is_nan(self.position.y):
		print("BAD STATE")
		self.queue_free()
	self._check_target_available()
	self._handle_pathfinding(delta)


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


func _get_base_alpha() -> float:
	var dist = MathUtils.normalize_range(
		(self.global_position - Scene.player.global_position).length(),
		self._appear_range,
		self._appear_range + 128
	)
	var alpha = MathUtils.interpolate(dist, 1, 0, MathUtils.INTERPOLATE_IN_EXPONENTIAL)
	# if alpha > 0 and not AI.has_LOS(self.global_position, Scene.player.global_position):
	# 	alpha = 0
	return alpha


func knockback(vel: Vector2):
	self.changev(LivingEntityVariable.VELOCITY, vel / getv(LivingEntityVariable.WEIGHT))


func update_health_bar():
	var bar = self.get_node("ProgressBar")
	bar.value = ((self.getv(LivingEntityVariable.HEALTH) / self.base_health) * 100)
	if bar.value == 0:
		bar.modulate.a = 0


func _on_take_damage(info: AttackInfo):
	self.fsm.set_state(EnemyState.PAIN)
	var direction = info.get_attack_direction(self.global_position)
	knockback(
		(
			direction
			* info.knockback_factor
			* self.getv(LivingEntityVariable.KNOCKBACK_FACTOR)
			/ self.getv(LivingEntityVariable.WEIGHT)
		)
	)

	var fx = HIT_SCENE.instance()
	fx.initialize(direction.angle(), info.damage)
	Scene.runtime.add_child(fx)
	if info.attack.damage_type == AttackVariable.DAMAGE_TYPE.RANGED:
		fx.global_position = info.attack.global_position
	else:
		fx.global_position = self.global_position
	._on_take_damage(info)


func get_x_direction():
	return -int(sign(flip_components.scale.x)) if flip_components.scale.x != 0 else -1


func _draw():
	if self.has_nav_path() and self.draw_path:
		var path = self.get_nav_path()
		path.draw(self)


func _on_death(info: AttackInfo):
	if info:
		var chance = (
			HEALTH_CHANCE_RANGED
			if info.attack.damage_type == AttackVariable.DAMAGE_TYPE.RANGED
			else HEALTH_CHANCE_MELEE
		)
		if randf() < chance:
			var pickup = HealthPickup.new()
			pickup.global_position = self.global_position * MathUtils.TO_ISO
			Scene.runtime.add_child(pickup)

	self.fsm.set_state(EnemyState.DEAD, true)
	self.fsm.lock()
	#self.queue_free()
