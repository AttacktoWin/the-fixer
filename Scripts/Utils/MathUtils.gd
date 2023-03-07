class_name MathUtils

const INTERPOLATE_LINEAR = 0
const INTERPOLATE_IN = 1
const INTERPOLATE_OUT = 2
const INTERPOLATE_SMOOTH = 3
const INTERPOLATE_IN_ELASTIC = 4
const INTERPOLATE_OUT_ELASTIC = 5
const INTERPOLATE_SMOOTH_ELASTIC = 6
const INTERPOLATE_IN_QUAD = 7
const INTERPOLATE_OUT_QUAD = 8
const INTERPOLATE_SMOOTH_QUAD = 9
const INTERPOLATE_IN_BACK = 10
const INTERPOLATE_OUT_BACK = 11
const INTERPOLATE_SMOOTH_BACK = 12
const INTERPOLATE_IN_EXPONENTIAL = 13
const INTERPOLATE_OUT_EXPONENTIAL = 14
const INTERPOLATE_SMOOTH_EXPONENTIAL = 15


static func vector_to_iso_vector(vec: Vector2) -> Vector2:
	return vec * Vector2(1, 0.5)


static func iso_vector_to_vector(vec: Vector2) -> Vector2:
	return vec * Vector2(1, 2)


static func scale_vector_to_iso(vec: Vector2) -> Vector2:
	var angle = vec.angle()
	return vec * (0.5 + abs(cos(angle)) / 2)


static func angle_to_iso_vector(val: float) -> Vector2:
	return vector_to_iso_vector(Vector2(cos(val), sin(val)))


static func interpolate_vector(vec, _min: float, _max: float, interp_type: int):
	if typeof(vec) == TYPE_VECTOR2:
		return Vector2(
			interpolate(vec.x, _min, _max, interp_type), interpolate(vec.y, _min, _max, interp_type)
		)
	if typeof(vec) == TYPE_VECTOR3:
		return Vector3(
			interpolate(vec.x, _min, _max, interp_type),
			interpolate(vec.y, _min, _max, interp_type),
			interpolate(vec.z, _min, _max, interp_type)
		)
	print("Input is not of type vector! ", vec)
	return vec


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
