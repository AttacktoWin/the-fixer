extends TextureButton

func _ready():
	connect("mouse_entered", self, "_on_mouse_entered")

func _on_mouse_entered():
	var owner = get_focus_owner()
	if owner:
		owner.release_focus()
	self.grab_focus()