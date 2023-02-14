# Author: Yalmaz
# Description: Enemy FSM extendied to be specific to the goomba enemy.
extends Generic_EnemyFSM

# Describes the distance the goomba hops when it gets into attack range
export(float) var hop_distance = 10.0
# Describes the time it takes to complete the hop
export(float) var hop_time = 0.6

export(float) var charge_time = 1.6

# Describes the distance the goomba lunges when attacking
export(float) var lunge_distance = 150.0
# Describes teh time taken to complete the lunge
export(float) var lunge_time = 0.6
