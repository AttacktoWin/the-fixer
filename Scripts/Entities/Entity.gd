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


func _ready():
	if self.height_component_path:
		self._height_components = get_node_or_null(self.height_component_path)
		if self._height_components:
			self._default_height = self._height_components.position.y


func _process(_delta):
	if self._height_components:
		var y = self._default_height - self._height
		self._height_components.position = Vector2(0, y)
