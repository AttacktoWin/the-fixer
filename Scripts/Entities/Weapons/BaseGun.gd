class_name BaseGun extends Weapon


func check_fire_pressed():
	return Input.is_action_just_pressed("weapon_fire_ranged")
