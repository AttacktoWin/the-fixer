extends Node2D


func _ready():
	pass


func _process(_delta):
	if Input.is_mouse_button_pressed(1):
		self.global_position = get_global_mouse_position()
