# Author: Marcus

extends Node2D
onready var nod:ColorRect = get_node("%ColorRect")

func _ready():
	self.scale = Vector2(1, 2)
	Scene.set_root(self)

func _process(_delta):
	var t = get_viewport().get_mouse_position()
	t.x/=get_viewport_rect().size.x
	t.y/=get_viewport_rect().size.y
	
