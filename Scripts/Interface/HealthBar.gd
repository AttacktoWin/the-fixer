extends HBoxContainer

var max_health = -1
var healthPip_scene = preload("res://Scenes/Interface/HealthPip.tscn")

var current_health = 10
var health_pips = []

func _ready():	
	Scene.connect("transition_complete", self, "reset_health")

func reset_health():
	if not Scene.player:
		return 
	
	max_health = Scene.player.getv(LivingEntityVariable.MAX_HEALTH)
	current_health = Scene.player.getv(LivingEntityVariable.HEALTH)
	
	for pip in health_pips:
		pip.queue_free()
	
	health_pips = []
	for pip in range (max_health):
		var health_pip = healthPip_scene.instance()
		add_child(health_pip)
		health_pips.append(health_pip)
	
	set_healthbar()

func set_healthbar():
	if (max_health!=-1):			
		for pip in range (max_health):
			if (pip<current_health):
				health_pips[pip].status = true
			else:
				health_pips[pip].status = false
func _process(_delta):
	set_healthbar()
