tool
class_name PCG_PopulatorData
extends Resource

export(int) var enemies_per_room = 5
export(int) var enemy_buffer = 2

export(Dictionary) var enemy_spawn_rate = {
		"pillbug": 30,
		"spyder": 70
	}

var enemy_scene = {
		"pillbug": load("res://Scenes/Enemies/E_Goomba.tscn"),
		"spyder": load("res://Scenes/Enemies/E_Spyder.tscn")
	}
