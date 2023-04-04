class_name BulletBase extends BaseAttack

onready var _sprite = $Sprite
onready var _hitbox_node = $Hitbox

var _wall_hitbox: Area2D = null


func _ready():
	self.is_ranged = true
	self._wall_hitbox = get_node("WallCollider")
	self._wall_hitbox.connect("body_entered", self, "_on_wall_body_entered")  #warning-ignore:return_value_discarded
	self.rotation = 0  # scuffed


func _on_hit_entity(_entity: LivingEntity):
	pass
	#Wwise.post_event_id(AK.EVENTS.HIT_PISTOL_PLAYER, self._damage_source)


func _on_wall_body_entered(body: Node2D):
	if body is TileMap and not self.spectral:
		self._expire()


func set_direction(dir: float):
	self.setv(AttackVariable.DIRECTION, dir)
	self._sprite.rotation = getv(AttackVariable.DIRECTION)
	self._hitbox_node.rotation = getv(AttackVariable.DIRECTION)


func _process(_delta):
	self.rotation = 0
	var r = getv(AttackVariable.DIRECTION)
	# self.ignore_wall_collisions = fmod(getv(AttackVariable.DIRECTION) + PI * 2, PI * 2) > PI
	self._sprite.rotation = r
	self._hitbox_node.rotation = r


func _physics_process(_delta):
	events.invoke(EVENTS.MOVE, null)
	var dir = getv(AttackVariable.DIRECTION)
	var speed = getv(AttackVariable.SPEED)
	self.position += Vector2(cos(dir), sin(dir)) * speed * _delta
