# Author: Marcus

class_name Manifestation extends LivingEntity

onready var hitbox: BaseAttack = $HitBox

var _start_position = Vector2()

const HIT_SCENE = preload("res://Scenes/Particles/HitScene.tscn")

var _enemy_info = [
	[8, load("res://Scenes/Enemies/E_Umbrella.tscn")],
	[20, load("res://Scenes/Enemies/E_Beetle.tscn")],
	[50, load("res://Scenes/Enemies/E_Spyder.tscn")],
	[100, load("res://Scenes/Enemies/E_Goomba.tscn")]
]

var _hard_enemy_info = [
	[15, load("res://Scenes/Enemies/E_Umbrella.tscn")],
	[35, load("res://Scenes/Enemies/E_Beetle.tscn")],
	[60, load("res://Scenes/Enemies/E_Spyder.tscn")],
	[100, load("res://Scenes/Enemies/E_Goomba.tscn")]
]

var _wave_counter = 0
var _timer = 0

const MAX_WAVE_TIME = 2


func get_display_name():
	return "Manifestation"


func _ready():
	self._start_position = self.global_position


func _enter_tree():
	CameraSingleton.set_controller(self)
	CameraSingleton.set_zoom(Vector2.ONE, self)
	CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM, self)


func _exit_tree():
	CameraSingleton.remove_controller(self)


func _physics_process(_delta):
	self._timer += _delta
	if self._timer > MAX_WAVE_TIME:
		self._timer = 0
		self._spawn_random_enemies(1)
	self.global_position = self._start_position
	_handle_camera()


func _handle_camera():
	var center = CameraSingleton.get_mouse_from_camera_center() / 360
	var off = (
		Vector2(
			MathUtils.interpolate(abs(center.x), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL),
			MathUtils.interpolate(abs(center.y), 0, 8, MathUtils.INTERPOLATE_OUT_EXPONENTIAL)
		)
		* Vector2(sign(center.x), sign(center.y))
	)
	var off2 = off + self.getv(LivingEntityVariable.VELOCITY) / 8
	CameraSingleton.set_target_center(
		MathUtils.to_iso(self.global_position * 4 + Scene.player.global_position) / 5 + off2, self
	)


func _on_take_damage(info: AttackInfo):
	var fx = HIT_SCENE.instance()
	var direction = info.get_attack_direction(self.global_position)
	fx.initialize(direction.angle(), info.damage)
	Scene.runtime.add_child(fx)
	if info.attack.damage_type == AttackVariable.DAMAGE_TYPE.RANGED:
		fx.global_position = info.attack.global_position
	else:
		fx.global_position = self.global_position
	._on_take_damage(info)


func select_enemy(enemies: Array, bias: float):
	var rng = pow(randf(), bias) * 100.0
	for data in enemies:
		if rng <= data[0]:
			return data[1].instance()

	print(rng)
	return enemies[0][1].instance()


func select_random_location():
	return Pathfinder.random_location_near(Vector2(0, 8 * Constants.TILE.HYP), 512.0)


func _spawn_random_enemies(
	count: int, use_hard_enemies: bool = false, difficulty_bias: float = 1.0
):
	var enemy_list = self._enemy_info
	if use_hard_enemies:
		enemy_list = self._hard_enemy_info

	for _x in range(count):
		var enemy = select_enemy(enemy_list, difficulty_bias)
		var loc = select_random_location()
		Scene.runtime.add_child(enemy)
		enemy.global_position = loc
