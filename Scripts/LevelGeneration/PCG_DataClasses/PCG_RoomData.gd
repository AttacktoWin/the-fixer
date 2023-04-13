class_name PCG_RoomData
extends Resource

enum MODE{ROOM,WALKED_ROOM}
var mode = MODE.ROOM
export(Vector2) var map_size = Vector2(40,40) 
export(int) var min_width = 10
export(int) var min_height = 10
export(int) var shrink_factor = 3
export(int) var corridor_width = 3
