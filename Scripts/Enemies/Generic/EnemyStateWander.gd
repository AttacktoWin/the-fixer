# Author: Marcus

class_name EnemyStateWander extends EnemyStateMoving

export var wander_radius: float = 256
export var walk_speed_multiplier: float = 0.333
export var draw_path: bool = false
var _home: Vector2 = Vector2(0, 0)
var _wander_timer: float = 0
var _path: PathfindResult = null

export var min_wander_delay: float = 0.25
export var max_wander_delay: float = 2
export var min_wander_distance_fac: float = 0.1


func get_handled_states():
	return [EnemyState.WANDER, EnemyState.IDLE]


func initialize():
	self.entity.connect("on_target_set", self, "target_set")
	self.entity.connect("on_investigate_target_set", self, "investigate_target_set")
	#self.entity.idle_collider.connect("body_entered", self, "on_body_entered")


func target_set(_target: LivingEntity):
	self.fsm.set_state(EnemyState.ALERTED)


func investigate_target_set(target: Vector2):
	if self.fsm.is_this_state(self):
		self._home = target
		self._path = Pathfinder.generate_path(self.entity.global_position, target)


func _check_body(body: KinematicBody2D):
	if (
		body is Player
		and not self.entity.has_target()
		and AI.has_LOS(self.global_position, body.global_position)
		and not body.is_dead()
	):
		self.entity.set_target(body)


func _check_for_targets():
	for target in self.entity.idle_collider.get_overlapping_bodies():
		_check_body(target)


func enter():
	self._home = self.entity.global_position
	self._path = null
	self._wander_timer = rand_range(self.min_wander_delay, self.max_wander_delay)
	self.entity.sprite_material.set_shader_param(Constants.SP.B_FLASH, false)
	self.entity.sprite_material.set_shader_param(Constants.SP.C_LINE_COLOR, Constants.COLOR.BLACK)
	self.entity.clear_investigate_target()
	self.entity.clear_target(false)


func _path_logic(delta):
	if self._path == null:
		self._wander_timer -= delta
		if self._wander_timer < 0 and self._generate_random_path():
			self._wander_timer = rand_range(self.min_wander_delay, self.max_wander_delay)


func _generate_random_path():
	var attempts = 10  # try at most 10 times to get the path...
	self._path = null
	while self._path == null and attempts > 0:
		var angle = randf() * PI * 2
		var dist = (
			(randf() + self.min_wander_distance_fac)
			/ (1 + self.min_wander_distance_fac)
			* wander_radius
		)
		var loc = self._home + Vector2(cos(angle) * dist, sin(angle) * dist)
		if Pathfinder.is_in_bounds(loc):
			self._path = Pathfinder.generate_path(self.entity.global_position, loc)
			if self._path.path_length() > self.wander_radius * 2:
				self._path = null
		attempts -= 1
	return self._path != null


func _follow_path(delta):
	if self._path == null:
		_try_move(delta, Vector2())
		return
	self._path.update(self.entity.global_position, self.entity.entity_radius)
	var dir = self.entity.apply_steering(self._path.get_target_vector())
	var vel = self.entity.get_wanted_velocity(dir) * walk_speed_multiplier
	_try_move(delta, vel)
	if self._path.is_path_complete():
		self._path = null


func _process(_delta):
	update()


func _physics_process(delta):
	_path_logic(delta)
	_follow_path(delta)
	self._animation_speed_multiplier = 2 if _is_moving() else 1
	_update_visuals()
	_check_for_targets()


func _draw():
	if self._path and self.draw_path:
		self._path.draw(self)


func exit():
	self.fsm.reset_animation_info()
	self._path = null
	update()
