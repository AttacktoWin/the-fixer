extends Control

export var game_url := "https://variable-eye-games.itch.io/within-the-vault"


func _on_TextureButton_pressed():
	OS.shell_open(game_url)


func _on_closed_pressed():
	self.visible = false
