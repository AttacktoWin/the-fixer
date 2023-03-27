class_name Constants extends Node2D

const TILE = {SIDE = 64, HYP = sqrt(64 * 64 * 2)}

const SP = {
	B_FLASH = "flash",
	C_FLASH_COLOR = "flash_color",
	C_LINE_COLOR = "line_color",
	I_LINE_THICKNESS = "line_thickness"
}

const COLOR = {
	YELLOW = Color(252 / 255.0, 216 / 255.0, 55 / 255.0),
	RED = Color(255 / 255.0, 30 / 255.0, 43 / 255.0),
	WHITE = Color(1.0, 1.0, 1.0, 1.0),
	INVISIBLE = Color(1.0, 1.0, 1.0, 0.0)
}

const TILE_TYPE = {
	VOID = -1,
	FLOOR = 1,
	WALL = 2,
}
