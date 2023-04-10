class_name Constants extends Node2D


class TILE:
	const SIDE = 64
	const HYP = sqrt(SIDE * SIDE * 2)


class SP:
	const B_FLASH = "flash"
	const C_FLASH_COLOR = "flash_color"
	const C_LINE_COLOR = "line_color"
	const I_LINE_THICKNESS = "line_thickness"


class COLOR:
	const YELLOW = Color(252 / 255.0, 216 / 255.0, 55 / 255.0)
	const RED = Color(255 / 255.0, 30 / 255.0, 43 / 255.0)
	const WHITE = Color(1.0, 1.0, 1.0, 1.0)
	const BLACK = Color(0.0, 0.0, 0.0, 1.0)
	const INVISIBLE = Color(1.0, 1.0, 1.0, 0.0)


class TILE_TYPE:
	const VOID = -1
	const FLOOR = 1
	const WALL = 2
