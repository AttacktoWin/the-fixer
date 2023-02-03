extends KinematicBody2D

enum { idle, alert, ready }

export(int) var sense_radius = 150
export(int) var attack_radius = 150
export(int) var speed = 100
export(NodePath) var player_path

onready var player = get_node(player_path)
var velocity := Vector2.ZERO
var state = idle


func _ready():
	pass


func _process(_delta):
	match state:
		idle:
			sensePlayer()
			print("idle")
		alert:
			chasePlayer()
			print("chase")
		ready:
			attackPlayer()
			print("attack")
	update()


func _physics_process(_delta):
	pass


func _draw():
	if state == idle:
		draw_circle(
			Vector2.ZERO,
			sense_radius,
			Color.red - Color(0, 0, 0, 0.5)
		)
	elif state == alert:
		draw_line(
			Vector2.ZERO,
			self.to_local(player.global_position),
			Color.white
		)

	draw_circle(
		Vector2.ZERO,
		attack_radius,
		Color.blue - Color(0, 0, 0, 0.5)
	)


func sensePlayer():
	var dist := self.global_position.distance_to(
		player.global_position
	)
	if dist <= sense_radius:
		state = alert


func chasePlayer():
	var dir = player.global_position - self.global_position
	if dir.length() <= attack_radius:
		state = ready
		return
	velocity = move_and_slide(speed * dir.normalized())


var timer = 0


func attackPlayer():
	while timer < 60:
		timer += 1
		yield()
	state = alert
	timer = 0
