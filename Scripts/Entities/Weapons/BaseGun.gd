# exclusively used by the player
class_name BaseGun extends Weapon


# override
func _on_fire_called():
	var angle1 = (CameraSingleton.get_absolute_mouse() - self.global_position).angle()
	var angle2 = (CameraSingleton.get_absolute_mouse() - self._get_aim_position()).angle()
	var angle = angle1 if abs(angle1 - angle2) < 0.1 else angle2
	# warning-ignore:return_value_discarded
	self._try_fire(angle, null)


func _check_fire_pressed():
	return Input.is_action_just_pressed("weapon_fire_ranged")
