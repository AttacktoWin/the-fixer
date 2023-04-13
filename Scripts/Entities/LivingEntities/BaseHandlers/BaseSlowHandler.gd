# Author: Marcus

class_name BaseSlowHandler extends Runnable

const SLOW_TIMER_FAC = 2  # 2 seconds
const SLOW_FAC = 0.25  # slow down to 0.25


func run(arg):
	var timer = self.entity.status_timers.get_timer(LivingEntityStatus.SLOWED)
	var interp = MathUtils.interpolate(
		timer / SLOW_TIMER_FAC, 1, SLOW_FAC, MathUtils.INTERPOLATE_OUT
	)
	return arg * interp
