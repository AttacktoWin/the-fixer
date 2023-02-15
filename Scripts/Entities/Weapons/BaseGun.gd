# exclusively used by the player
class_name BaseGun extends Weapon


# override
func _on_fire_called():
	var angle = (CameraSingleton.get_absolute_mouse() - self._get_aim_position()).angle()
	self._try_fire(angle, null)


func _check_fire_pressed():
	return Input.is_action_just_pressed("weapon_fire_ranged")
