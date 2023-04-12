extends ColorRect

enum MENU { NONE, PAUSE, SETTING }

var current = MENU.NONE
var paused = false


func _ready():
	$PauseMenu/VBoxContainer/Resume.connect("button_down", self, "_resume")  #warning-ignore:return_value_discarded
	$PauseMenu/VBoxContainer/Exit.connect("button_down", self, "_exit")  #warning-ignore:return_value_discarded


func _input(event):
	if event is InputEventKey and event.pressed:
		if Input.is_action_pressed("ui_cancel"):
			if paused:
				Wwise.set_state_id(AK.STATES.GAMEPAUSED.GROUP, AK.STATES.GAMEPAUSED.STATE.NO)
				$PauseMenu.visible = false
				self.visible = false
				paused = false
				PausingSingleton.unpause()
			else:
				if PausingSingleton.is_paused():
					return
				Wwise.set_state_id(AK.STATES.GAMEPAUSED.GROUP, AK.STATES.GAMEPAUSED.STATE.YES)
				#Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, 100)
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
		Wwise.set_state_id(AK.STATES.GAMEPAUSED.GROUP, AK.STATES.GAMEPAUSED.STATE.NO)


func _exit():
	$PauseMenu.visible = false
	self.visible = false
	paused = false
	PausingSingleton.unpause()
	Scene.switch(load("res://Scenes/Interface/Menus/MainMenu.tscn").instance())
