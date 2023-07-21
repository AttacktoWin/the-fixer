extends Node

signal update_avaliable
var update_available := false
var current_version: String
var channel_name: String
var available_patches := []
const PATCHES_PATH := "res://Scripts/Patches"

# Called when the node enters the scene tree for the first time.
func _ready():
	var f = File.new()
	f.open("res://VERSIONFILE", File.READ)
	self.current_version = f.get_as_text()
	f.close()
	
	match OS.get_name():
		"Windows":
			self.channel_name = "win"
		"macOS":
			self.channel_name = "osx"
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			self.channel_name = "linux"

func _input(_event):
	pass
	# if Input.is_action_just_pressed("show_enemies"):
	# 	emit_signal("update_avaliable")

func load_patches(saved_patches: Dictionary):
	var request = HTTPRequest.new()
	request.connect("request_completed", self, "_on_request_completed")
	request.request("https://itch.io/api/1/x/wharf/latest?game_id=2002925&channel_name=" + self.channel_name)
	if (saved_patches.has("patches")):
		var dir = Directory.new()
		if (dir.open(PATCHES_PATH) == OK):
			dir.list_dir_begin(true)
			var file_name = dir.get_next()
			while file_name != "":
				if (!(file_name in saved_patches["patches"])):
					var patch = load(file_name)
					if (!SaveHelper.run_patch(patch)):
						print("Couldn't run patch", file_name)
					file_name = dir.get_next()
	
func _on_request_completed(result, response_code, headers, body):
	if (response_code == 200):
		if (!self.current_version):
			# first patch
			self.update_available = true
			emit_signal("update_avaliable")
		else:
			var newest_version = body.get_string_from_utf8()
			if (newest_version != self.current_version):
				self.update_available = true
				emit_signal("update_avaliable")
