extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#Load a bank for use, make sure that init is loaded first
	Wwise.load_bank_id(AK.BANKS.INIT) 
	Wwise.load_bank_id(AK.BANKS.MAIN)
	
	#Register a listener
	#Wwise.register_listener(self)
	# update listener position
	Wwise.set_2d_position(self, self.get_global_transform) 
	
	#Post an event to play a sound
	#Register a GameObject, then call post_event on registered GameObject
	Wwise.register_game_obj(self, self.get_name())
	Wwise.post_event_id(AK.EVENTS.FIRE_PISTOL_PLAYER, self)



# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	pass
