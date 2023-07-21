class_name VolumeSlider
extends HSlider

enum TRACK { MASTER, MUSIC, COMBAT }
export(TRACK) var track

func _ready():
	reset_value()
	connect("mouse_entered", self, "_on_mouse_entered")

func reset_value():
	if track == TRACK.MASTER:
		self.value = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.MASTER, Scene)
	if track == TRACK.MUSIC:
		self.value = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, Scene)
	if track == TRACK.COMBAT:
		self.value = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.EFFECTVOLUME, Scene)



func _on_HSlider_value_changed(value):

	if track == TRACK.MASTER:
		Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MASTER, value, Scene)
	if track == TRACK.MUSIC:
		Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, value, Scene)
	if track == TRACK.COMBAT:
		Wwise.set_rtpc_id(AK.GAME_PARAMETERS.EFFECTVOLUME, value, Scene)

func _on_mouse_entered():
	var owner = get_focus_owner()
	if owner:
		owner.release_focus()
	self.grab_focus()