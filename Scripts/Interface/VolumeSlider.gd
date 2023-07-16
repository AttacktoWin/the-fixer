class_name VolumeSlider
extends HSlider

enum TRACK { MASTER, MUSIC, COMBAT }
export(TRACK) var track

func _ready():
	reset_value()

func reset_value():
	if track == TRACK.MASTER:
		self.value = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.EFFECTVOLUME, Scene) # TODO
	if track == TRACK.MUSIC:
		self.value = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, Scene)
	if track == TRACK.COMBAT:
		self.value = Wwise.get_rtpc_id(AK.GAME_PARAMETERS.EFFECTVOLUME, Scene)



func _on_HSlider_value_changed(value):

	if track == TRACK.MASTER:
		Wwise.set_rtpc_id(AK.GAME_PARAMETERS.EFFECTVOLUME, value, Scene) # TODO
	if track == TRACK.MUSIC:
		Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, value, Scene)
	if track == TRACK.COMBAT:
		Wwise.set_rtpc_id(AK.GAME_PARAMETERS.EFFECTVOLUME, value, Scene)
