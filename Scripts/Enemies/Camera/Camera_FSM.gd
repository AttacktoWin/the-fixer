# Author: Yalmaz
# Description: Enemy FSM extendied to be specific to the spyder enemy.
extends Generic_EnemyFSM

# Range of the flash effect.
export(float) var flash_range = 90.0

# Used to see if flash attack has been used before.
var is_flashON = false
