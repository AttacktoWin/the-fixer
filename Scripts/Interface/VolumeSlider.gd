extends HSlider

enum TRACK {MASTER,MUSIC,COMBAT}
export(TRACK) var track

func _on_HSlider_value_changed(value):
	print(value)
	var banks = Scene.get_tree().get_nodes_in_group("bank")
	print(Wwise.get_rtpc(AK.GAME_PARAMETERS.MUSICVOLUME,banks[2]))
#	get_node("../../../../../Managers/AkBank-MUSIC")))
#	print(Wwise.set_rtpc_id(AK.GAME_PARAMETERS.MUSICVOLUME,0.5,self))
