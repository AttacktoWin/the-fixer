class_name SingleHitFilter extends HitFilter

var _already_hit = []


func can_hit(object: LivingEntity):
	if self._already_hit.has(object):
		return false
	self._already_hit.append(object)
	return true
