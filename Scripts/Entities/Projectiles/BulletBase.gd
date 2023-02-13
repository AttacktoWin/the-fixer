class_name BulletBase extends Area2D

enum EVENTS { CREATE, STEP, MOVE, HIT_WALL, HIT_ENEMY, DESTROY }
var events = DecoratorList.new(EVENTS)

# when attempting to access a variable
enum VARIABLE { SPEED, DAMAGE, DIRECTION, LIFE }  # (self, current) -> return next
var variables = VariableList.new(
	VARIABLE, {VARIABLE.SPEED: 500, VARIABLE.DAMAGE: 1, VARIABLE.DIRECTION: 0, VARIABLE.LIFE: 2.0}
)


func set_direction(dir):
	variables.set_variable(VARIABLE.DIRECTION, dir)


func set_damage(dmg):
	variables.set_variable(VARIABLE.DAMAGE, dmg)


func set_speed(spd):
	variables.set_variable(VARIABLE.SPEED, spd)


func set_lifetime(life):
	variables.set_variable(VARIABLE.LIFE, life)


func _expire():
	self.queue_free()


func _process(delta):
	# does not use a timer
	var current = variables.get_variable(VARIABLE.LIFE) - delta
	variables.set_variable(VARIABLE.LIFE, current)
	if current < 0:
		self._expire()


func _physics_process(_delta):
	events.invoke(EVENTS.MOVE, null)
	var dir = self.variables.get_variable(VARIABLE.DIRECTION)
	var speed = self.variables.get_variable(VARIABLE.SPEED)
	var vel = Vector2(cos(dir), sin(dir)) * speed * _delta
	self.position += vel
