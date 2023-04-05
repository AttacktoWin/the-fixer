# Author: Marcus

class_name WorldWeapon extends WorldPickup

export(PackedScene) var weapon_scene = null
var weapon_instance: Weapon = null


func _ready():
	if not self.weapon_scene and not self.weapon_instance:
		print("ERR: no weapon for world weapon to load!")
		return
	set_weapon(self.weapon_instance if self.weapon_instance else self.weapon_scene.instance())
	set_texture(self.weapon_instance.world_sprite)


func set_weapon(weapon: Weapon):
	weapon.set_process(false)
	weapon.set_physics_process(false)
	self.weapon_instance = weapon


func on_collected(collector):
	Wwise.post_event_id(AK.EVENTS.WEAPON_PICKUP_PLAYER, self)
	self.weapon_instance.set_process(true)
	self.weapon_instance.set_physics_process(true)
	collector.set_gun(self.weapon_instance)
	self.weapon_instance = null
