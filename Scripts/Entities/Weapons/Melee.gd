class_name Melee extends Node2D

export(PackedScene) var visual_scene = null
export(Texture) var world_sprite = null

export var damage_override: float = -1
export var knockback_override: float = -1
export var hitbox_size_override: float = -1
export var attack_speed: float = 1.0

var attack_speed_multiplier = 1.0

var upgrade_handler = UpgradeHandler.new(self, UpgradeType.MELEE)

var entity = null


func _init(_parent_entity: LivingEntity = null):
	self.entity = _parent_entity


func with_parent(parent_entity: LivingEntity):
	self.entity = parent_entity
	return self


func with_visuals(visuals: Node2D):
	if visuals != null:
		visuals.add_child(self)
		return visuals
	return self


func apply_to_attack(attack: BaseAttack):
	if self.damage_override >= 0:
		attack.setv(AttackVariable.DAMAGE, self.damage_override)
	if self.knockback_override >= 0:
		attack.setv(AttackVariable.KNOCKBACK, self.knockback_override)
	if self.hitbox_size_override >= 0:
		attack.scale = Vector2.ONE * self.hitbox_size_override


func default_visual_scene():
	if self.visual_scene:
		return self.visual_scene.instance()
	return null
