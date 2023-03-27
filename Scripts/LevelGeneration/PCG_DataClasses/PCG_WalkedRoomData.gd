class_name PCG_WalkedRoomData
extends PCG_RoomData

enum CARDINAL_DIR{N,S,E,W}

export(CARDINAL_DIR) var start_direction = CARDINAL_DIR.N
export(int) var walk_length = 110
export(int) var max_steps_in_direction = 2
export(int) var walker_width = 3
export(float) var random_turn_chance = 0.25

func _init():
	self.mode = MODE.WALKED_ROOM
