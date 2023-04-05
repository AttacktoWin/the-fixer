extends ColorRect

enum MENU { NONE,PAUSE,SETTING }

var current = MENU.NONE
var paused = false

func _ready():
	$PauseMenu/VBoxContainer/Resume.connect("button_down",self,"_resume")
	$PauseMenu/VBoxContainer/Exit.connect("button_down",self,"_exit")

func _input(event):
	if event is InputEventKey and event.pressed:
		if Input.is_action_pressed("ui_cancel"):
			if paused:
				$PauseMenu.visible = false
				self.visible = false
				paused = false
				PausingSingleton.unpause()
			else:
				self.visible = true
				$PauseMenu.visible = true
				paused = true
				PausingSingleton.pause()

func _resume():
	if paused:
		$PauseMenu.visible = false
		self.visible = false
		paused = false
		PausingSingleton.unpause()

func _exit():
	$PauseMenu.visible = false
	self.visible = false
	paused = false
	PausingSingleton.unpause()
	get_tree().change_scene("res://Scenes/Interface/Menus/MainMenu.tscn")
