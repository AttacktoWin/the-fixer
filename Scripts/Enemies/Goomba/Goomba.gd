# Author: Marcus

class_name Goomba extends BaseEnemy

func _process(delta):
	._process(delta)
	$CanvasLayer.offset = MathUtils.from_iso(self.position)
