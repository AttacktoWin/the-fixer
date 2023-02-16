class_name BaseAttack extends Area2D

enum EVENTS { CREATE, STEP, MOVE, HIT_WALL, HIT_ENEMY, DESTROY }
var events = DecoratorList.new(EVENTS)

export var base_speed: float = 500
export var base_damage: float = 50
export var base_direction: float = 0
export var base_lifetime: float = 2.0
# when attempting to access a variable
onready var variables = VariableList.new(
	AttackVariable.get_script_constant_map(),
	{
		AttackVariable.SPEED: base_speed,
		AttackVariable.DAMAGE: base_damage,
		AttackVariable.DIRECTION: base_direction,
		AttackVariable.LIFE: base_lifetime
	}
)

var _attack = null
var _damage_dealer = null


func _ready():
	add_child(variables)
	add_child(events)
	self.rotation = self.variables.get_variable(AttackVariable.DIRECTION)
	self.initialize()


func initialize(damage_dealer = null, attack = null):
	if self._damage_dealer == null:
		self._damage_dealer = self.owner if damage_dealer == null else damage_dealer
	if self._attack == null:
		self._attack = AttackHandler.new(self._damage_dealer, self) if attack == null else attack
	return self


func set_damage_dealer(dealer: LivingEntity):
	self._damage_dealer = dealer


func set_attack(attack):
	self._attack = attack


func set_direction(dir):
	variables.set_variable(AttackVariable.DIRECTION, dir)


func set_damage(dmg):
	variables.set_variable(AttackVariable.DAMAGE, dmg)


func set_speed(spd):
	variables.set_variable(AttackVariable.SPEED, spd)


func set_lifetime(life):
	variables.set_variable(AttackVariable.LIFE, life)


func _expire():
	self.queue_free()


func _process(delta):
	# does not use a timer
	var current = self.variables.get_variable(AttackVariable.LIFE) - delta
	self.variables.set_variable(AttackVariable.LIFE, current)


func _physics_process(_delta):
	pass
