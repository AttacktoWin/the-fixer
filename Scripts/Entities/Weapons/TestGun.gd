class_name TestGun extends Weapon

var BulletScene = preload("res://Scenes/Weapons/bullet_scene.tscn")


func _fire(_direction, _target = null):
	var bullet: BulletBase = BulletScene.instance()
	bullet.position = Vector2(self._parent.position.x, self._parent.position.y)
	bullet.set_direction(_direction)
	get_tree().get_root().add_child(bullet)
