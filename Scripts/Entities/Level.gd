# Author: Marcus

extends Node2D

func _ready():
	Scene.set_root(self)
	Scene._player = Scene._root.get_node("Level/Generator").get_node("%Player")
