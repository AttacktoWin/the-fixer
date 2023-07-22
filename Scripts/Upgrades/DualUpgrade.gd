class_name DualUpgrade extends Node2D

var _upgrade1 = null
var _upgrade2 = null

var _collected = false

const SCENE = preload("res://Scenes/Upgrades/UpgradeScene.tscn")


func _ready():
	var upgrades = UpgradeSingleton.pick_upgrade_pair()
	self._upgrade1 = SCENE.instance()
	self._upgrade2 = SCENE.instance()

	self._upgrade1.set_upgrade_name(upgrades[0])
	self._upgrade2.set_upgrade_name(upgrades[1])

	add_child(self._upgrade1)
	add_child(self._upgrade2)

	self._upgrade1.global_position.x -= 128
	self._upgrade2.global_position.x += 128

	self._upgrade1.handle_pickup = false
	self._upgrade2.handle_pickup = false

	self.process_priority = -1;


func is_collected():
	return self._collected


func _physics_process(_delta):
	if not is_instance_valid(self._upgrade1):
		queue_free()
		return

	if self._collected:
		return

	if Input.is_action_just_pressed("pickup_weapon") and not PausingSingleton.is_paused_recently() and not Scene.is_input_marked("pickup_weapon"):
		var selected = null
		var dist = 1
		if self._upgrade1.collect_range_normalized() < dist:
			selected = self._upgrade1
			dist = self._upgrade1.collect_range_normalized()

		if self._upgrade2.collect_range_normalized() < dist:
			selected = self._upgrade2
			dist = self._upgrade2.collect_range_normalized()

		if selected:
			self._collected = true
			selected.collect(Scene.player)
			self._upgrade1.kill()
			self._upgrade2.kill()
			Scene.mark_input("pickup_weapon")
