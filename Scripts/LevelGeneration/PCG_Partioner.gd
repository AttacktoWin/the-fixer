class_name PCG_Partioner
extends Node

var rng = RandomNumberGenerator.new()

var space = Rect2(0,0,50,50)
var min_width = 10
var min_height = 10
func _init():
	rng.randomize()

func _ready():
	pass # Replace with function body.

func room_builder():
	var room_list = binar_space_partition()
	#for each rect:
		

func binar_space_partition():
	var roome_queue = []
	var room_list = []
	roome_queue.push_back(space)
	
	while(roome_queue.size()>0):
		var candidate:Rect2 = roome_queue.pop_front()
		if candidate.size.x >= min_width:
			var new_partitions = _split_horizontal(candidate)
			roome_queue.push_back(new_partitions[0])
			roome_queue.push_back(new_partitions[1])
		elif candidate.size.y >= min_height:
			#split vert
			pass
		else:
			room_list.push_back(candidate)
	return room_list


func _split_horizontal(space:Rect2):
	var x_split = rng.randi_range(1,space.size.x)
	var a = Rect2(
		space.position,
		Vector2(x_split,space.size.y)
		)
	var b = Rect2(
		Vector2(x_split,space.position.y),
		Vector2(space.size.x - x_split,space.size.y)
		)
	return [a,b]


func _split_vertical():
	pass
