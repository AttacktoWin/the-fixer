# Author: Marcus

class_name Entity extends KinematicBody2D

export(NodePath) var height_component_path = NodePath("Visual")
export var entity_radius: float = 32

var _height_components: Node2D = null

var _height: float = 0
var _default_height: float = 0

var _shadow: Sprite = null
const SHADOW_TEX = preload("res://Assets/Sprites/Shadow/dropshadow.png")

const MAX_SHADOW_HEIGHT: float = 64.0
const MIN_SHADOW_VALUE: float = 0.5

const SHADOW_SIZE: float = 300.0


func set_height(height: float):
	self._height = height


func get_height() -> float:
	return self._height


func set_height_component(component: Node2D):
	if self._height_components:
		self._height_components.position = Vector2(
			self._height_components.position.x, self._default_height
		)
	self._height_components = component
	self._default_height = self._height_components.position.y


func _ready():
	self._shadow = Sprite.new()
	self._shadow.texture = SHADOW_TEX
	self._shadow.scale = Vector2.ONE * self.entity_radius * 2.0 / SHADOW_SIZE
	self._shadow.modulate.a = MIN_SHADOW_VALUE
	add_child(self._shadow)
	move_child(self._shadow, 0)
	if self.height_component_path:
		var component = get_node_or_null(self.height_component_path)
		if component:
			set_height_component(component)


func _process(_delta):
	if self._height_components:
		var y = self._default_height - self._height
		self._height_components.position = Vector2(self._height_components.position.x, y)
		var interp = clamp(1 - (self._height / MAX_SHADOW_HEIGHT), 0, 1)
		self._shadow.modulate.a = interp * MIN_SHADOW_VALUE
		self._shadow.scale = Vector2.ONE * self.entity_radius * 2.0 / SHADOW_SIZE * MathUtils.interpolate(interp, 0.75, 1, MathUtils.INTERPOLATE_LINEAR)
		if self == self._height_components:
			self._shadow.position = Vector2(0, self._height)
