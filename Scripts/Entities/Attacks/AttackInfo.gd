# Author: Marcus

class_name AttackInfo extends Resource

var damage_source = null
var damage_type: int = -1
var damage_location: Vector2 = Vector2.ZERO
var attack = null
var damage: float = 0
var direction: float = 0
var knockback_factor: float = 0
var stun_factor: float = 0


func _init(
	damage_source_arg,
	damage_type_arg,
	damage_location_arg: Vector2,
	attack_arg,
	damage_arg: float,
	direction_arg: float,
	knockback_factor_arg: float,
	stun_factor_arg: float
):
	self.damage_source = damage_source_arg
	self.damage_type = damage_type_arg
	self.damage_location = damage_location_arg
	self.attack = attack_arg
	self.damage = damage_arg
	self.direction = direction_arg
	self.knockback_factor = knockback_factor_arg
	self.stun_factor = stun_factor_arg


func get_attack_direction(to: Vector2) -> Vector2:
	if self.damage_location.x != INF:
		return (to - self.damage_location).normalized()
	return Vector2(cos(self.direction), sin(self.direction))
