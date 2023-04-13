extends ColorRect
var player_node:KinematicBody2D

var _enabled: bool = false

func _ready():
	Scene.connect("world_updated", self, "_reload")
	
func _reload():
	self._enabled = Scene.level_node.vision_enabled
	var alpha = 0.0
	var vision_range = 0.3
	if Scene.level_node.vision_enabled:
		alpha = Scene.level_node.vision_alpha
		vision_range = Scene.level_node.vision_range
	modulate.a = alpha
	material.set_shader_param("mask_radius",vision_range-0.02)
		

func _process(_delta):
	if not self._enabled:
		return
	player_node = Scene.player
	var player_pos = player_node.get_global_transform_with_canvas().origin
	var target = player_pos/get_viewport_rect().size
	material.set_shader_param("target",target)
