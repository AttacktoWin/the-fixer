# data class which determines add
class_name AttackHandler extends Object

var _damage_dealer = null
var _damage_owner = null
var _hit_handler = null
var _hitbox = null
var _filter = null
var _hitbox_proxy = null


func _init(damage_dealer, damage_owner, hitbox = null, filter = null):
	self._damage_dealer = damage_dealer
	self._damage_owner = damage_owner
	self._hit_handler = BaseHitHandler.new(damage_owner)
	self._hitbox = hitbox if hitbox else damage_owner
	self._filter = filter if filter else HitFilter.new()  # always returns true...
	self._hitbox_proxy = HitboxProxy.new(self, self._hitbox)


func with_hit_handler(handler):
	self._hit_handler = handler
	return self


func get_damage_owner():
	return self._damage_owner


func get_hitbox():
	return self._hitbox


func try_hit_entity(body: Node):
	if not (body is LivingEntity):
		return
	# TEMP
	# if self._damage_dealer == body:
	# 	return
	if not self._try_filter_entity(body):
		return
	self._on_hit_entity_success(body)


func _try_filter_entity(body: LivingEntity):
	if self._filter.can_hit(body):
		return true
	return false


func _on_hit_entity_success(body: LivingEntity):
	var success = body.can_be_hit()
	if success:
		self._hit_handler.on_hit(body)
		self._on_hit_success(body)
	else:
		self._on_hit_failure(body)


# implement as signals and in subclasses...


#warning-ignore:unused_argument
func _on_filter_fail(body: LivingEntity):
	return


#warning-ignore:unused_argument
func _on_hit_success(body: LivingEntity):
	return


#warning-ignore:unused_argument
func _on_hit_failure(body: LivingEntity):
	return
