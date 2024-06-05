extends HBoxContainer

var max_health = 10
var healthPip_scene = preload("res://Scenes/Interface/HealthPip.tscn")

var current_health = 10
var health_pips = []

func _ready():
	current_health = max_health
	for pip in range (max_health):
		var health_pip = healthPip_scene.instance()
		add_child(health_pip)
		health_pips.append(health_pip)
	
func _process(_delta):
	for pip in range (max_health):
		if (pip<current_health):
			health_pips[pip].status = true
		else:
			health_pips[pip].status = false
