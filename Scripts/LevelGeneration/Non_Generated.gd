extends Node
export(Vector2) var map_size = Vector2(10, 10)
var level = []  #-1 = non, 1 = floor, 2 = wall


func _ready():
	var floor_set: TileMap = get_node("%Floor")
	var wall_set: TileMap = get_node("%Walls")
	var pit_set: TileMap = get_node("%Pits")
	for x in range(0, self.map_size.x + 1):
		self.level.push_back([])
		for y in range(0, self.map_size.x + 1):
			if pit_set.get_cell(x, y) != TileMap.INVALID_CELL:
				self.level[x].push_back(2)
			elif wall_set.get_cell(x, y) != TileMap.INVALID_CELL:
				self.level[x].push_back(2)
			elif floor_set.get_cell(x, y) != TileMap.INVALID_CELL:
				self.level[x].push_back(1)
			else:
				self.level[x].push_back(-1)

func set_seed(_value):
	pass

func get_seed():
	return 0