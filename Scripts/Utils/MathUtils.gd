class_name MathUtils

const INTERPOLATE_LINEAR: int = 0
const INTERPOLATE_IN: int = 1
const INTERPOLATE_OUT: int = 2
const INTERPOLATE_SMOOTH: int = 3
const INTERPOLATE_IN_ELASTIC: int = 4
const INTERPOLATE_OUT_ELASTIC: int = 5
const INTERPOLATE_SMOOTH_ELASTIC: int = 6
const INTERPOLATE_IN_QUAD: int = 7
const INTERPOLATE_OUT_QUAD: int = 8
const INTERPOLATE_SMOOTH_QUAD: int = 9
const INTERPOLATE_IN_BACK: int = 10
const INTERPOLATE_OUT_BACK: int = 11
const INTERPOLATE_SMOOTH_BACK: int = 12
const INTERPOLATE_IN_EXPONENTIAL: int = 13
const INTERPOLATE_OUT_EXPONENTIAL: int = 14
const INTERPOLATE_SMOOTH_EXPONENTIAL: int = 15
const FROM_ISO: Vector2 = Vector2(1, 2)
const TO_ISO: Vector2 = Vector2(1, 0.5)


static func from_iso(vec: Vector2) -> Vector2:
	return vec * FROM_ISO


static func to_iso(vec: Vector2) -> Vector2:
	return vec * TO_ISO


# converts a worldspace vector to a level space vector clamped to the tilemap
static func to_level_vector(vec: Vector2, _clamp: bool = true) -> Vector2:
	vec = vec.rotated(-PI / 4)
	var x = vec.x / Constants.TILE.HYP
	var y = vec.y / Constants.TILE.HYP
	if not _clamp:
		return Vector2(x, y)

	var level = Scene.level
	var x_max = level.size()
	var y_max = level[0].size()
	return Vector2(clamp(x, 0, x_max - 0.00001), clamp(y, 0, y_max - 0.00001))


static func from_level_vector(vec: Vector2) -> Vector2:
	var x = vec.x * Constants.TILE.HYP
	var y = vec.y * Constants.TILE.HYP
	return Vector2(x, y).rotated(PI / 4)


static func interpolate_vector(val: float, _min, _max, interp_type: int):
	if typeof(_min) == TYPE_VECTOR2:
		return Vector2(
			interpolate(val, _min.x, _max.x, interp_type),
			interpolate(val, _min.y, _max.y, interp_type)
		)
	if typeof(_min) == TYPE_VECTOR3:
		return Vector3(
			interpolate(val, _min.x, _max.x, interp_type),
			interpolate(val, _min.y, _max.y, interp_type),
			interpolate(val, _min.z, _max.z, interp_type)
		)
	print("Input is not of type vector! ", _min)
	return _min


static func interpolate_color(val: float, color1: Color, color2: Color, interp_type: int):
	return Color(
		interpolate(val, color1.r, color2.r, interp_type),
		interpolate(val, color1.g, color2.g, interp_type),
		interpolate(val, color1.b, color2.b, interp_type),
		interpolate(val, color1.a, color2.a, interp_type)
	)


static func angle_difference(angle1: float, angle2: float) -> float:
	return fposmod(angle1 - angle2 + PI, PI * 2) - PI


static func line_coords_world(start: Vector2, end: Vector2) -> Array:
	return line_coords(to_level_vector(start), to_level_vector(end))


static func line_coords(start: Vector2, end: Vector2) -> Array:
	var x = floor(start.x)
	var y = floor(start.y)

	if start == end:
		return [Vector2(x, y)]

	var dx = end.x - start.x
	var dy = end.y - start.y
	var stepX = sign(dx)
	var stepY = sign(dy)

	var xOffset = (ceil(start.x) - start.x) if end.x > start.x else (start.x - floor(start.x))
	var yOffset = (ceil(start.y) - start.y) if end.y > start.y else (start.y - floor(start.y))

	var angle = atan2(-dy, dx)
	var c = cos(angle)
	var s = sin(angle)
	if s == 0:
		s = 0.000000000001
	if c == 0:
		c = 0.000000000001

	var tMaxX = xOffset / c
	var tMaxY = yOffset / s

	var tDeltaX = 1.0 / c
	var tDeltaY = 1.0 / s

	# Travel one grid cell at a time.
	var dist = abs(floor(end.x) - floor(start.x)) + abs(floor(end.y) - floor(start.y))

	var points = []

	for _t in range(dist + 1):
		points.append(Vector2(x, y))

		if abs(tMaxX) < abs(tMaxY):
			tMaxX += tDeltaX
			x += stepX
		else:
			tMaxY += tDeltaY
			y += stepY

	return points


static func abs_x(vec):
	return Vector2(abs(vec.x), vec.y)


static func floor_vec2(vec):
	return Vector2(floor(vec.x), floor(vec.y))


# converts delta from seconds to frames
static func delta_frames(delta):
	return delta * 60


static func normalize_range(val: float, _min: float, _max: float) -> float:
	var diff = _max - _min
	if diff == 0:
		return 0.5
	return clamp((val - _min) * (1 / diff), 0, 1)


static func interpolate(val: float, _min: float, _max: float, interp_type: int) -> float:
	var diff = _max - _min
	if val >= 1:
		return _max

	if val <= 0:
		return _min

	match interp_type:
		INTERPOLATE_LINEAR:
			return diff * val + _min
		INTERPOLATE_IN:
			return diff * (val * val * val) + _min
		INTERPOLATE_OUT:
			var t = val - 1
			return diff * (t * t * t + 1) + _min
		INTERPOLATE_SMOOTH:
			return diff * (3 * val * val - 2 * val * val * val) + _min
		INTERPOLATE_IN_QUAD:
			return diff * val * val + _min
		INTERPOLATE_OUT_QUAD:
			return diff * (val * (2 - val)) + _min
		INTERPOLATE_SMOOTH_QUAD:
			return diff * (2 * val * val if val < 0.5 else -1 + (4 - 2 * val) * val) + _min
		# following 3 functions written by Chriustian Figueroa https://github.com/ChristianFigueroa
		# source: https://gist.github.com/gre/1650294#gistcomment-1892122
		INTERPOLATE_IN_ELASTIC:
			return diff * ((0.04 - 0.04 / val) * sin(25 * val) + 1) + _min
		INTERPOLATE_OUT_ELASTIC:
			var v1 = val - 1
			return diff * (((0.04 * val) / v1) * sin(25 * v1)) + _min
		INTERPOLATE_SMOOTH_ELASTIC:
			val = val - 0.5
			if val == 0:
				val = 0.000001
			return (
				(
					diff
					* (
						(0.02 + 0.01 / val) * sin(50 * val)
						if val < 0
						else (0.02 - 0.01 / val) * sin(50 * val) + 1
					)
				)
				+ _min
			)
		# following 6 functions written by Girish Budhwani https://github.com/girish3
		# source: https://gist.github.com/girish3/11167208
		INTERPOLATE_IN_BACK:
			var s = 1.70158
			return diff * (val * val * ((s + 1) * val - s)) + _min
		INTERPOLATE_OUT_BACK:
			var s = 1.70158
			return diff * ((val - 1) * val * ((s + 1) * val + s) + 1) + _min
		INTERPOLATE_SMOOTH_BACK:
			var s = 2.5949095
			val = val + val
			if val < 1:
				return diff * ((1 / 2) * (val * val * ((s + 1) * val - s))) + _min
			val = val - 2
			return diff * ((1 / 2) * (val * val * ((s + 1) * val + s) + 2)) + _min
		INTERPOLATE_IN_EXPONENTIAL:
			return diff * pow(2, 10 * (val - 1)) + _min
		INTERPOLATE_OUT_EXPONENTIAL:
			return diff * (-pow(2, -10 * val) + 1) + _min
		INTERPOLATE_SMOOTH_EXPONENTIAL:
			val = val + val
			if val < 1:
				return diff * ((1 / 2) * pow(2, 10 * (val - 1))) + _min
			return diff * ((1 / 2) * (-pow(2, -10 * (val - 1)) + 2)) + _min

	print("Unknown interp type: ", interp_type)
	return 0.0
