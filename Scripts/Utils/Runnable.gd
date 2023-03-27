class_name Runnable extends Node2D

var entity = null
var default_value = null


func _init(_default_value = null):
	self.default_value = false


func _ready():
	set_process(false)
	set_physics_process(false)


func _on_added():
	pass


func _on_removed():
	pass


func _process(_delta):
	pass


func _physics_process(_delta):
	pass


# warning-ignore:unused_argument
func clone(new_parent):
	return duplicate()


func run(_arg):
	print("Not implemented!!!")
