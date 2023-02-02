extends Node2D


func _process(_delta):
	if Input.is_action_just_pressed("test"):
		position = get_global_mouse_position()
	update()
	pass


func _draw():
	draw_circle(Vector2.ZERO, 300, Color.red - Color(0, 0, 0, 0.5))
	draw_circle(Vector2.ZERO, 200, Color.blue - Color(0, 0, 0, 0.5))
