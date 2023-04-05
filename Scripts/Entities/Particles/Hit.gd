# Author: Marcus

class_name WeaponHitParticle extends Node2D

export var lifetime: float = 0.8
export var flash_time: float = 0.4
export(PackedScene) var vfx_scene = null
export var rotate_components_path: String = "Rotate"
export var damage_label_path: String = "DamageLabel"

var _vfx: Node2D = null
var _rotate_components: Node2D = null
var _damage_label: Label = null

var _wanted_rotation: float = 0.0
var _damage: int = 0

var _rand_angle = rand_range(-60, 60)
var _velocity = Vector2(rand_range(-10, 10), rand_range(-20, -60))

var _timer: float = 0.0
const FLASH_RATE: float = 0.1

const COLOR1 = Constants.COLOR.RED
const COLOR2 = Constants.COLOR.WHITE


func initialize(rotation: float = 0, damage: int = 0):
	self._wanted_rotation = rotation
	self._damage = damage


func _ready():
	if not self.vfx_scene:
		print("ERR: no vfx scene for hit particle")
		self.queue_free()
		return
	self._vfx = self.vfx_scene.instance()
	add_child(self._vfx)
	self._rotate_components = self._vfx.get_node_or_null(NodePath(self.rotate_components_path))
	self._damage_label = self._vfx.get_node_or_null(NodePath(self.damage_label_path))
	if self._rotate_components:
		self._rotate_components.rotation = self._wanted_rotation
	if self._damage_label:
		self._damage_label.text = String(self._damage)


func _handle_text():
	if not self._damage_label:
		return
	var m = fmod(self._timer, FLASH_RATE)
	if m < FLASH_RATE / 2 or self._timer > self.flash_time:
		self._damage_label.modulate = COLOR1
	else:
		self._damage_label.modulate = COLOR2

	self._damage_label.rect_position += self._velocity
	self._velocity *= 0.75

	self._damage_label.rect_rotation = MathUtils.interpolate(
		self._timer / self.lifetime, 0.0, self._rand_angle, MathUtils.INTERPOLATE_OUT_EXPONENTIAL
	)

	self._damage_label.rect_scale = (
		Vector2.ONE
		* MathUtils.interpolate(
			self._timer / self.lifetime, 1, 2, MathUtils.INTERPOLATE_OUT_EXPONENTIAL
		)
	)

	if self._timer > self.flash_time:
		var move = MathUtils.interpolate(
			MathUtils.normalize_range(self._timer, self.flash_time, self.lifetime),
			0,
			30,
			MathUtils.INTERPOLATE_IN
		)
		self._damage_label.rect_position += Vector2(0, move)


func _process(delta):
	self._timer += delta
	_handle_text()
	self.modulate.a = MathUtils.interpolate(
		MathUtils.normalize_range(self._timer, self.flash_time, self.lifetime),
		1,
		0,
		MathUtils.INTERPOLATE_OUT_EXPONENTIAL
	)
	if self._timer > self.lifetime:
		self.queue_free()
