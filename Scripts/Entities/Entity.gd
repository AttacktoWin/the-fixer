# Author: Marcus

class_name Entity extends KinematicBody2D

export(NodePath) var height_component_path = NodePath("Visual")

var _height_components: Node2D = null

var _height: float = 0
var _default_height: float = 0


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
	if self.height_component_path:
		var component = get_node_or_null(self.height_component_path)
		if component:
			set_height_component(component)


func _process(_delta):
	if self._height_components:
		var y = self._default_height - self._height
		self._height_components.position = Vector2(self._height_components.position.x, y)
