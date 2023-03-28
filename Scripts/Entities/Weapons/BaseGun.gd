# exclusively used by the player
class_name BaseGun extends Weapon


func _init(parent_entity).(parent_entity):
	self._ammo_count = 2


# override
func _on_fire_called():
	var angle1 = MathUtils.to_iso(CameraSingleton.get_absolute_mouse() - self.global_position).angle()
	var angle2 = MathUtils.to_iso(CameraSingleton.get_absolute_mouse() - self._get_aim_position()).angle()
	var angle = angle1 if abs(angle1 - angle2) < 0.1 else angle2
	# warning-ignore:return_value_discarded
	self._try_fire(angle, null)


func _check_fire_pressed():
	return not PausingSingleton.is_paused_recently() and Input.is_action_pressed("weapon_fire_ranged")
