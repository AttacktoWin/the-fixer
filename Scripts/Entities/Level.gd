extends Node2D

export (NodePath) var level_path

func _ready():
	Scene.set_root(self)
