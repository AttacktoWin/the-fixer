# Author: Marcus

class_name Manifestation extends LivingEntity

onready var hitbox: BaseAttack = $HitBox
onready var fsm: FSMController = $FSMController

var _start_position = Vector2()

const HIT_SCENE = preload("res://Scenes/Particles/HitScene.tscn")

var _enemy_info = [
	[10, load("res://Scenes/Enemies/E_Beetle.tscn")],
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

var _death_timer = 0

const MAX_WAVE_TIME = 2
const WAVE_DIFFICULTY_FACTOR = 1.25


func get_entity_name():
	return "Manifestation"


func _ready():
	Wwise.register_game_obj(self, name)
	self._start_position = self.global_position
	StatsTracker.add_manifestation_fight()


func _enter_tree():
	CameraSingleton.set_controller(self)
	CameraSingleton.set_zoom(Vector2.ONE, self)
	CameraSingleton.jump_field(CameraSingleton.TARGET.ZOOM, self)


func _exit_tree():
	CameraSingleton.remove_controller(self)


func _boss_logic(delta):
	self._timer += delta


func _dead_logic(delta):
	self._death_timer += delta
	CameraSingleton.shake_max(
		MathUtils.interpolate(self._death_timer / 3.0, 30, 0, MathUtils.INTERPOLATE_OUT)
	)
	if self._death_timer > 4:
		TransitionHelper.transition(load("res://Scenes/Levels/Hub.tscn").instance(), false, false)


func _physics_process(delta):
	if not self.is_dead():
		self._boss_logic(delta)
	else:
		self._dead_logic(delta)
	self.global_position = self._start_position
	_handle_camera()


func _handle_camera():
	if self.is_dead() or self.fsm.current_state_name() == ManifestationState.SPAWNING_WAVE:
		CameraSingleton.set_target_center(MathUtils.to_iso(self.global_position), self)
		return
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

	return enemies[0][1].instance()


func select_random_location():
	return Pathfinder.random_location_near(Vector2(0, 8 * Constants.TILE.HYP), 512.0)


func on_damage_orb_hit(orb, _bounce):
	var fx = preload("res://Scenes/Particles/HitScene.tscn").instance()
	fx.initialize(orb.get_angle(), 50)
	Scene.runtime.add_child(fx)
	fx.global_position = orb.global_position
	fx.scale = Vector2(1, 1)
	fx.z_index = 1
	CameraSingleton.shake(10)
	self._take_damage(50)
	pass


func on_enemy_death(enemy):
	if self.is_dead():
		return
	var part = preload("res://Scenes/Manifestation/ManifestationDamageOrb.tscn").instance()
	part.set_target(self)
	part.collect_sound = null
	part.connect("on_reached_target", self, "on_damage_orb_hit")
	Scene.runtime.add_child(part)
	part.global_position = enemy.global_position
	part.modulate = Constants.COLOR.RED


func _spawn_random_enemies(
	count: int, use_hard_enemies: bool = false, difficulty_bias: float = 1.0
):
	Wwise.post_event_id(AK.EVENTS.SUMMON_MANIFESTATION, self)
	var enemy_list = self._enemy_info
	if use_hard_enemies:
		enemy_list = self._hard_enemy_info

	for _x in range(count):
		var enemy = select_enemy(enemy_list, difficulty_bias)
		var loc = select_random_location()
		Scene.runtime.add_child(enemy)
		enemy.global_position = loc
		enemy.connect("on_death", self, "on_enemy_death")


func _on_death(_info: AttackInfo):
	StatsTracker.add_manifestation_win()
	self.fsm.set_state(ManifestationState.DEAD, true)
	self.fsm.lock()


func increment_wave():
	self._wave_counter += 1


func spawn_enemy_context():
	var hard = self._wave_counter >= 4
	_spawn_random_enemies(1, hard, pow(WAVE_DIFFICULTY_FACTOR, self._wave_counter))
