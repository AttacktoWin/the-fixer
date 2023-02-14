# Author: Yalmaz
# Description: HurtBox for enemies. Only detects hits from hitboxes that have hurtInfo.
class_name Generic_Hurtbox
extends Area2D


########################################################################
#Overrides
########################################################################
func _init() -> void:
	collision_layer = 0
	collision_mask = 2


func _ready() -> void:
	#warning-ignore:RETURN_VALUE_DISCARDED
	connect("area_entered", self, "_on_area_entered")


func _on_area_entered(hitbox) -> void:
	if not "hurt_info" in hitbox:
		return

	if owner.has_method("on_Hurt") and hitbox.can_hurt(self):
		owner.on_Hurt(hitbox.hurt_info)
