# Author: Marcus

class_name LimitedSoundBullet extends BulletBase

var _connected_bullets = [self]
var _entity_counts = {}

const MAX_COUNT = 2


func add_connected_bullet(bullet: LimitedSoundBullet):
	self._connected_bullets.append(bullet)


func _notify_entity_hit(entity: LivingEntity):
	if entity in self._entity_counts:
		self._entity_counts[entity] += 1
	else:
		self._entity_counts[entity] = 1


func _on_hit_entity(entity: LivingEntity):
	for bullet in self._connected_bullets:
		if is_instance_valid(bullet):
			bullet._notify_entity_hit(entity)

	if self._entity_counts[entity] <= MAX_COUNT:
		._on_hit_entity(entity)
