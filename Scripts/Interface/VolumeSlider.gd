extends HSlider

enum TRACK { MASTER, MUSIC, COMBAT }
export(TRACK) var track


func _on_HSlider_value_changed(value):
	print(Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, value, Scene))
	print(Wwise.get_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME, Scene))
#	get_node("../../../../../Managers/AkBank-MUSIC")))
#	print(Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME,0.5,self))
