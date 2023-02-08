class_name DialogueQueue

extends Object

const Dialogue = preload("res://Scripts/DialogueSystem/classes/Dialogue.gd")

var heap: Array
var size: int

func _init() -> void:
	heap = []
	size = 0
	
# Used when loading the dialogue system from a save file
func init_with_items(items: Array) -> void:
	heap = items;
	size = len(items);
	_minheapify(0);

func _swap(lhs: int, rhs: int) -> void:
	var tmp = heap[lhs];
	heap[lhs] = heap[rhs];
	heap[rhs] = tmp;

func _parent(key: int) -> int:
	return (key - 1) / 2;
	
func _left(key: int) -> int:
	return 2 * key + 1;
	
func _right(key: int) -> int:
	return 2 * key + 2;
	
func _decrease_key(key: int, new_priority: int) -> void:
	heap[key].priority = new_priority;
	
	while (key != 0 && heap[key].priority < heap[_parent(key)].priority):
		_swap(key, _parent(key));
		key = _parent(key)
		
func _minheapify(key: int) -> void:
	var l = _left(key);
	var r = _right(key);
	
	var smallest = key;
	if (l < size && heap[l].priority < heap[smallest].priority):
		smallest = l;
	if (r < size && heap[r].priority < heap[smallest].priority):
		smallest = r;
	
	if (smallest != key):
		_swap(key, smallest);
		_minheapify(smallest);
		
func _find_item_index(item_id: String, key: int) -> int:
	if (heap[key].id == item_id):
		return key;
	if (key >= len(heap)):
		return -1;
	if (!is_instance_valid(heap[key])):
		# Not a node so no children
		return -1;
	var lhs = _find_item_index(item_id, _left(key));
	if (is_instance_valid(lhs)):
		return lhs;
	var rhs = _find_item_index(item_id, _right(key));
	return rhs;
		
func enqueue(d: Dialogue) -> void:
	var i = size;
	heap.append(d);
	size += 1;
	
	while (i != 0 && heap[i].priority < heap[_parent(i)].priority):
		_swap(i, _parent(i));
		i = _parent(i);
		
func peek() -> Dialogue:
	return heap[0];
	
func dequeue() -> Dialogue:
	if (size <= 0):
		return null;
	
	if (size == 1):
		var minimum = heap[0];
		heap.clear();
		size = 0;
		return minimum;
	
	var root = heap[0];
	heap[0] = heap[size - 1];
	size -= 1;
	_minheapify(0);
	
	return root;
	
func remove(item_id: String) -> void:
	var key = _find_item_index(item_id, 0);
	if (key != -1):
		_decrease_key(key, -1);
		dequeue();
		
func _get_children(key: int) -> Array:
	if (key >= len(heap)):
		return [];
	if (!is_instance_valid(heap[key])):
		return [];
	return [heap[key]] + _get_children(_left(key)) + _get_children(_right(key));

func get_contents() -> Array:
	return _get_children(0);
