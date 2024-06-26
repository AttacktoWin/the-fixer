extends ColorRect

enum MENU { NONE, PAUSE, SETTING }

var current = MENU.NONE
var paused = false


func _ready():
	$PauseMenu/VBoxContainer/Resume.connect("button_down", self, "_resume")  #warning-ignore:return_value_discarded
	$PauseMenu/VBoxContainer/Settings.connect("button_down", self, "_settings_open")  #warning-ignore:return_value_discarded
	# $Settings/VBoxContainer/Cancel.connect("button_down", self, "_settings_close")  #warning-ignore:return_value_discarded
	$PauseMenu/VBoxContainer/Exit2HUB.connect("button_down", self, "_exit2hub")  #warning-ignore:return_value_discarded
	$PauseMenu/VBoxContainer/Exit.connect("button_down", self, "_exit")
	$Settings/Save/Save.connect("button_down", self, "_save_settings")
	$Settings/Save/Cancel.connect("button_down", self, "_cancel_settings")

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") and (Scene.level_node and Scene.level_node.level_index != -3):
		if paused:
			Wwise.set_state_id(AK.STATES.GAMEPAUSED.GROUP, AK.STATES.GAMEPAUSED.STATE.NO)
			$PauseMenu.visible = false
			if $Settings.visible:
				_cancel_settings()
				return
			$Settings.visible = false
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
			$PauseMenu/VBoxContainer/Resume.grab_focus()
			paused = true
			PausingSingleton.pause()

func _save_settings():
	SaveHelper.save_settings()
	SaveHelper.load_settings() # reload keymapping
	_pause_open()

func _cancel_settings():
	SaveHelper.load_settings()
	_pause_open()

func _resume():
	if paused:
		$PauseMenu.visible = false
		self.visible = false
		paused = false
		PausingSingleton.unpause()
		Wwise.set_state_id(AK.STATES.GAMEPAUSED.GROUP, AK.STATES.GAMEPAUSED.STATE.NO)

func _pause_open():
	$PauseMenu.visible = true
	$Settings.visible = false
	$PauseMenu/VBoxContainer/Resume.grab_focus()

func _settings_open():
	$PauseMenu.visible = false
	$Settings.visible = true
	$"Settings/TabContainer/Audio/Audio Settings".reload_sliders()
	$"Settings/TabContainer/Controls/InputMapper".reload_inputs()
	$"Settings/TabContainer/Audio/Audio Settings/Master/HSlider".grab_focus()

func _exit2hub():
	$PauseMenu.visible = false
	self.visible = false
	paused = false
	PausingSingleton.unpause()
	Scene.switch(load("res://Scenes/Levels/Hub.tscn").instance())
	Wwise.set_state_id(AK.STATES.GAMEPAUSED.GROUP, AK.STATES.GAMEPAUSED.STATE.NO)

func _exit():
	$PauseMenu.visible = false
	self.visible = false
	paused = false
	PausingSingleton.unpause()
	Scene.switch(load("res://Scenes/Interface/Menus/MainMenu.tscn").instance())
	Wwise.set_state_id(AK.STATES.GAMEPAUSED.GROUP, AK.STATES.GAMEPAUSED.STATE.NO)
