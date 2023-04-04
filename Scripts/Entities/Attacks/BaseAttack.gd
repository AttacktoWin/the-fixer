# Author: Marcus

class_name BaseAttack extends Node2D

enum EVENTS { CREATE, STEP, MOVE, HIT_WALL, HIT_ENEMY, DESTROY }
onready var events: DecoratorList

var variables: VariableList = null

export var base_speed: float = 500
export var base_damage: float = 50
export var base_direction: float = 0
export var base_lifetime: float = 2.0
export(NodePath) var hitbox_path = null  # assumed self otherwise
export(GDScript) var allied_class = null  # this class will be ignored for attacks
export(AttackVariable.ATTACK_TYPE) var attack_type = AttackVariable.ATTACK_TYPE.CONTINUOUS
export var attack_interval: float = 0.25
export(AttackVariable.DAMAGE_TYPE) var damage_type = AttackVariable.DAMAGE_TYPE.MELEE
export var persistent: bool = false
export var die_on_pierce: bool = true
export var spectral: bool = false
export var ignore_wall_collisions: bool = true
export var camera_shake: float = 3
export var knockback_factor: float = 32
export var stun_factor: float = 1
export var max_pierce: int = 1
export var can_hit_self: bool = false
export var ignore_rotation: bool = false
export var should_forget_entities: bool = false
export var entity_forget_time: float = 1  # useful for repeating attacks
var _hitbox: Area2D = null

# runtime vars
var _pierce: int = 0
var _hit_entities: Dictionary = {}
var _current_time: float = 0.0
var _countdown_timer: float = 0.0

var _damage_source: LivingEntity = null


func _ready():
	self.events = DecoratorList.new(self, EVENTS)
	self.variables = VariableList.new(
		self,
		AttackVariable.get_script_constant_map(),
		{
			AttackVariable.SPEED: base_speed,
			AttackVariable.DAMAGE: base_damage,
			AttackVariable.DIRECTION: base_direction,
			AttackVariable.LIFE: base_lifetime
		}
	)
	add_child(variables)
	add_child(events)
	self._damage_source = self._damage_source if self._damage_source else owner
	self._hitbox = get_node(hitbox_path) if hitbox_path else self
	self._hitbox.connect("body_entered", self, "_on_body_entered")  # warning-ignore:return_value_discarded
	self._hitbox.connect("area_entered", self, "_on_area_entered")  # warning-ignore:return_value_discarded
	self.rotation = getv(AttackVariable.DIRECTION)


func set_damage_source(entity: LivingEntity):
	self._damage_source = entity
	return self


func get_damage_source():
	return self._damage_source


func reset():
	self._pierce = 0
	self._hit_entities = {}


func _generate_attack_info(_entity: LivingEntity) -> AttackInfo:
	return AttackInfo.new(
		self._damage_source,
		self.damage_type,
		Vector2(INF, INF),
		self,
		self.getv(AttackVariable.DAMAGE),
		self.getv(AttackVariable.DIRECTION),
		self.knockback_factor,
		self.stun_factor
	)


func _on_hit_entity(_entity: LivingEntity):
	pass


func _hit_entity(entity: LivingEntity, info: AttackInfo) -> void:
	self._hit_entities[entity] = self._current_time
	self._pierce += 1
	CameraSingleton.shake(self.camera_shake)
	entity.on_hit(info)
	_on_hit_entity(entity)
	if self.die_on_pierce and self._pierce >= max_pierce:
		_expire()


func _filter_entity(entity: LivingEntity) -> bool:
	if self._damage_source == entity and not self.can_hit_self:
		return false

	if self.allied_class and entity is self.allied_class:
		return false

	if entity.is_dead():
		return false

	if not entity.can_be_hit():
		return false

	if not self._hit_entities.has(entity):
		return true

	var time = self._hit_entities[entity]
	if self.should_forget_entities and self._current_time - time > self.entity_forget_time:
		self._hit_entities[entity] = self._current_time
		return true

	return false


func _try_hit_entity(entity: LivingEntity) -> bool:
	if self._pierce >= self.max_pierce:
		return false

	if not _filter_entity(entity):
		return false

	var info = _generate_attack_info(entity)
	if not entity.can_attack_hit(info):
		return false

	_hit_entity(entity, info)
	return true


func _on_body_entered(body: Node2D):
	if not ignore_wall_collisions and body is TileMap and not self.spectral:
		self._expire()
	if (
		self.attack_type != AttackVariable.ATTACK_TYPE.CONTINUOUS
		or not (body is LivingEntity)
		or body == null
	):
		return

	self._try_hit_entity(body)  # warning-ignore:return_value_discarded


func _on_area_entered(body: Node2D):
	if body.owner is LivingEntity:
		self._on_body_entered(body.owner)


func invoke_attack():
	for entity in self._hitbox.get_overlapping_bodies():
		if entity != null and entity is LivingEntity:
			self._try_hit_entity(entity)  # warning-ignore:return_value_discarded
	for entity in self._hitbox.get_overlapping_areas():
		if entity.owner != null and entity.owner is LivingEntity:
			self._try_hit_entity(entity.owner)  # warning-ignore:return_value_discarded


func set_direction(dir: float):
	self.setv(AttackVariable.DIRECTION, dir)
	self.rotation = self.getv(AttackVariable.DIRECTION)


func setv(variable: int, value):
	return self.variables.set_variable(variable, value)


func getv(variable: int):
	return self.variables.get_variable(variable)


func changev(variable: int, off):
	return setv(variable, getv(variable) + off)


func _expire():
	self.queue_free()


func _process(_delta):
	if not self.ignore_rotation:
		self.rotation = getv(AttackVariable.DIRECTION)


func _physics_process(delta):
	var current_life = self.changev(AttackVariable.LIFE, -delta)
	if current_life < 0 and not self.persistent:
		self._expire()

	self._current_time += delta

	if self.attack_type == AttackVariable.ATTACK_TYPE.INTERVAL:
		self._countdown_timer -= delta
		if self._countdown_timer < 0:
			self._countdown_timer = self.attack_interval
			self.invoke_attack()
