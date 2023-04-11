class_name SmoothProgress extends ProgressBar

const SMOOTH_FAC = 0.1

var target_value = 0.0


func _process(delta):
	self.value += (self.target_value - self.value) * pow(SMOOTH_FAC, MathUtils.delta_frames(delta))
