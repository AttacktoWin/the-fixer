# Author: Marcus

extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	CameraSingleton.set_camera(self)
