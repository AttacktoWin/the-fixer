# Author: Marcus

class_name WorldUpgrade extends Entity

export var handle_pickup = false
export var pickup_distance = 96

var _upgrade_name = null

var _visuals = null

var _sprite1 = null
var _sprite2 = null
var _upgrade_sprite = null

var _text = null

var _timer1 = 0
var _timer2 = 0

var _show_timer = 0

var _collected = false

var _die_timer = 0


func _init(upgrade_name = null):
	if upgrade_name != null:
		set_upgrade_name(upgrade_name)


func set_upgrade_name(val: String):
	self._upgrade_name = val
	if self._text:
		self._text.text = UpgradeSingleton.get_upgrade_description(self._upgrade_name)
		self._upgrade_sprite.frame = UpgradeSingleton.get_upgrade_tex_frame(self._upgrade_name)


func _ready():
	self.z_index = 1
	set_shadow_appear_distance(256)
	set_height(40)

	self._sprite1 = get_node("Visual/Sprite1")
	self._sprite1.modulate.a = 0.8

	self._sprite2 = get_node("Visual/Sprite2")
	self._sprite2.modulate.a = 0.5

	self._upgrade_sprite = get_node("Visual/UpgradeSprite")

	self._text = get_node("Visual/Label")
	self._text.modulate.a = 0.0

	set_upgrade_name(self._upgrade_name)


func collect_range_normalized():
	return (Scene.player.global_position - self.global_position).length() / pickup_distance


func collect(collector: LivingEntity):
	if self._collected:
		return
	self._collected = true
	collector.apply_upgrades([UpgradeSingleton.name_to_upgrade(self._upgrade_name).new()])


func kill():
	self._collected = true


func _physics_process(_delta):
	var change = -_delta
	var dist = collect_range_normalized()
	if dist <= 1:
		change = -change
		if self.handle_pickup and Input.is_action_just_pressed("pickup_weapon"):
			collect(Scene.player)

	self._show_timer = clamp(self._show_timer + change, 0, 1)

	self._text.modulate.a = MathUtils.interpolate(
		_show_timer, 0, 1, MathUtils.INTERPOLATE_OUT_EXPONENTIAL
	)
	self._text.rect_position = MathUtils.interpolate_vector(
		_show_timer, Vector2(-116, -80), Vector2(-116, -95), MathUtils.INTERPOLATE_OUT_EXPONENTIAL
	)

	self._timer1 += 0.05
	self._timer2 += 0.218934

	set_height(40 + cos(self._timer1 / 3.45) * 13)

	var tscale = MathUtils.interpolate(1 - self._timer1 / 6, 1, 0, MathUtils.INTERPOLATE_IN_BACK)

	self._sprite1.scale = Vector2.ONE * (sin(self._timer1) + 6) / 7 * 0.25 * tscale
	self._sprite2.scale = Vector2.ONE * (sin(self._timer2) + 2) / 3 * 0.16 * tscale

	self._upgrade_sprite.scale = (
		Vector2(sin(self._timer1) / 8.6 + 2.5, sin(self._timer2) / 8.6 + 2.5)
		* 0.312
		* tscale
	)
	self._upgrade_sprite.modulate.a = sin(self._timer1 * 0.83) / 12 + 0.66

	if self._collected:
		self._die_timer += _delta
		set_height(
			get_height() + MathUtils.interpolate(self._die_timer, 0, -90, MathUtils.INTERPOLATE_IN_BACK)
		)
		self.modulate.a = MathUtils.interpolate(self._die_timer, 1, 0, MathUtils.INTERPOLATE_OUT)
		if self._die_timer > 1:
			queue_free()
