# Author: Marcus

class_name WorldPickup extends Entity

export var lifetime: float = 10
export var lives_forever: float = true
export var pickup_distance: float = 128
export var auto_pickup: bool = true
export var pickup_height: float = 64

const DEFAULT_TEXTURE = preload("res://Assets/Tiles/Hub/wall0010.png")
var _texture = null

var _life_timer = 0
var _timer = 0

var _collection_timer = 0
var _collected = false

var _sprite = null

const CYCLE_TIME = 4
const SPIN_TIME = 1
const COLLECTION_TIME = 2

const FADE_OUT_TIME = 3

signal on_collected


func _ready():
	Wwise.register_game_obj(self, self.get_name())
	if get_node_or_null(self.height_component_path) == null:
		set_height_component(self)
	if not self._texture:
		self._texture = DEFAULT_TEXTURE

	self._sprite = Sprite.new()
	self._sprite.texture = self._texture
	self._sprite.scale = Vector2(0.6, 0.6)
	self.add_child(self._sprite)


func set_texture(tex: Texture):
	if tex:
		self._sprite.texture = tex


func collect(collector: LivingEntity):
	if not self._collected:
		self._collected = true
		on_collected(collector)
		emit_signal("on_collected", self, collector)
		return true
	return false


func on_collected(_collector: LivingEntity):
	pass


func collection_check(_collector: LivingEntity) -> bool:
	return true


func _physics_process(_delta):
	var dist = (Scene.player.global_position - self.global_position).length()
	if dist < self.pickup_distance and collection_check(Scene.player):
		if self.auto_pickup:
			collect(Scene.player)
		else:
			if Input.is_action_just_pressed("pickup_weapon"):
				collect(Scene.player)


func _process(delta):
	#print(self._height_components)
	._process(delta)

	var height = sin(self._timer * PI * 2.0 / CYCLE_TIME * 2.0) * 10 + 20

	if self._collected:
		self._collection_timer += delta
		self.scale.x = 1
		self.set_height(
			(
				MathUtils.interpolate(
					self._collection_timer / COLLECTION_TIME,
					0,
					pickup_height,
					MathUtils.INTERPOLATE_OUT_EXPONENTIAL
				)
				+ height
			)
		)
		var v = self._collection_timer - COLLECTION_TIME + 1
		if v < 0:
			var m = abs(fmod(v, 0.2))
			if m < 0.1:
				self.modulate.a = 0.5
			else:
				self.modulate.a = 0.25
		if v > 0:
			var interp = MathUtils.interpolate(v * 2, 1, 0, MathUtils.INTERPOLATE_IN_BACK)
			self.scale.x = interp
			self.modulate.a = interp / 2.0
		if v > 0.5:
			self.queue_free()
		return

	if not self.lives_forever:
		self._life_timer += delta
		var v = self._life_timer - self.lifetime + FADE_OUT_TIME
		var interp = MathUtils.interpolate(v / FADE_OUT_TIME, 1, 0, MathUtils.INTERPOLATE_OUT)
		self.modulate.a = interp

	self._timer += delta

	self.set_height(height)
	var v = fmod(self._timer, CYCLE_TIME)
	if v < CYCLE_TIME / 2.0:
		self.scale.x = MathUtils.interpolate(
			MathUtils.normalize_range(v, CYCLE_TIME / 2.0 - SPIN_TIME, CYCLE_TIME / 2.0),
			1,
			-1,
			MathUtils.INTERPOLATE_IN_ELASTIC
		)
	else:
		self.scale.x = MathUtils.interpolate(
			MathUtils.normalize_range(v, CYCLE_TIME - SPIN_TIME, CYCLE_TIME),
			-1,
			1,
			MathUtils.INTERPOLATE_IN_ELASTIC
		)
