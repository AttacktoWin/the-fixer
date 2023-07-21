# Author: Marcus
# Author: Yalmaz

extends Node
# Exists only to preload Wwise... Might do more later


# Called when the node enters the scene tree for the first time.
func _ready():
	var debug_result
	debug_result = Wwise.load_bank_id(AK.BANKS.INIT)
	debug_result = Wwise.load_bank_id(AK.BANKS.MUSIC)
	debug_result = Wwise.load_bank_id(AK.BANKS.UI)
	debug_result = Wwise.load_bank_id(AK.BANKS.GAMEPLAY)

# Wwise examples:

# in init
# Register a listener
# Wwise.register_listener(self)
# Wwise.register_game_obj(self, self.get_name())

# in process
# Wwise.set_2d_position(self, self.global_position)

# play the sound (note: id is basically just a string and it is up to evan to add the corresponding sound. any value is accepted
# Wwise.post_event_id(AK.EVENTS.DASH_PLAYER, Scene)
