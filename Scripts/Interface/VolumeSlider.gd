class_name VolumeSlider
extends HSlider

enum TRACK { MASTER, MUSIC, COMBAT }
export(TRACK) var track
export var autofocus: bool = false

func _ready():
	reset_value()
	connect("mouse_entered", self, "_on_mouse_entered")


func _process(_delta):
	if not self.is_visible_in_tree() or not autofocus or not Scene.is_controller():
		return
	var focus_owner = get_focus_owner()
	if focus_owner == null or not focus_owner.is_inside_tree() or not focus_owner.is_visible_in_tree():
		self.grab_focus()

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