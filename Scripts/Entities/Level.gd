# Author: Marcus

extends Node2D


func _ready():
	self.scale = Vector2(1, 2)
	Scene.set_root(self)
