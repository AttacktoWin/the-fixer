class_name BaseAttack extends Area2D

enum EVENTS { CREATE, STEP, MOVE, HIT_WALL, HIT_ENEMY, DESTROY }
var events = DecoratorList.new(EVENTS)

# when attempting to access a variable
var variables = VariableList.new(
	AttackVariable.get_script_constant_map(),
	{
		AttackVariable.SPEED: 500,
		AttackVariable.DAMAGE: 50,
		AttackVariable.DIRECTION: 0,
		AttackVariable.LIFE: 2.0
	}
)

var _attack = null


func _ready():
	add_child(variables)
	add_child(events)
	self.rotation = self.variables.get_variable(AttackVariable.DIRECTION)

	if not self._attack:
		self._attack = AttackHandler.new(self)


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
