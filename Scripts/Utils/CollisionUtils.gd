# Author: Marcus

class_name CollisionUtils


# resistant to null area2d and filters
static func get_overlapping_bodies_filtered(area2d, _self = null, limit_to = Node):
	if not area2d:
		return []
	var overlapping = area2d.get_overlapping_bodies()
	var arr = []
	for x in overlapping:
		if x is limit_to and x != _self:
			arr.append(x)
	return arr
