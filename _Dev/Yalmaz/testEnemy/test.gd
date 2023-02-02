extends Node2D

var sense_radius = 200
export(NodePath) var player_path

onready var player = get_node(player_path)


func _ready():
	pass


func _process(_delta):
	sensePlayer()
	update()
	pass


func _draw():
	draw_circle(Vector2.ZERO, 200, Color.red - Color(0, 0, 0, 0.5))
	draw_line(Vector2.ZERO, self.to_local(player.position), Color.white)


func sensePlayer():
	var dis = self.global_position.distance_to(player.global_position)
	print(global_position)
	print(player.global_position)
	print(dis)


func isInPosition():
	pass


func moveToJumpRange():
	pass


func jumpToPosition():
	pass


func aim():
	pass


func charge():
	pass


func attack():
	pass
