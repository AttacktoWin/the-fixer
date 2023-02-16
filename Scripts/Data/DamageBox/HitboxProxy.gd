class_name HitboxProxy extends Object

var _hitbox = null
var _attack_handler = null  # type = AttackHandler


func _init(attack_handler, hitbox = null):
	self._attack_handler = attack_handler
	if hitbox:
		self.set_hitbox(hitbox)
	self._hitbox = hitbox


func set_hitbox(hitbox):
	if self._hitbox:
		print("Already connected!")
		self.remove_hitbox()
	self._hitbox = hitbox
	self._hitbox.connect("body_entered", self, "_on_body_entered")
	self._hitbox.connect("area_entered", self, "_on_area_entered")


func remove_hitbox():
	if not self._hitbox:
		print("No hitbox!")
	self._hitbox.disconnect("body_entered", self, "_on_body_entered")
	self._hitbox.disconnect("area_entered", self, "_on_area_entered")
	self._hitbox = null


func _on_body_entered(body: Node):
	self._attack_handler.try_hit_entity(body)


func _on_area_entered(body: Area2D):
	self._attack_handler.try_hit_entity(body.owner)


func get_hitbox():
	return self._hitbox


func cleanup():
	pass
