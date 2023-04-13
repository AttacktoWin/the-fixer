class_name AK

class EVENTS:

	const ATTACK_BIRD = 2348673105 
	const NOTICE_BIRD = 1274459313 
	const SHOOT_BIRD = 2396170652 
	const CRASH_BEETLE = 2212742940 
	const NOTICE_BEETLE = 3277391769 
	const ATTACK_SPYDER = 1294487939 
	const FIRE_PISTOL_PLAYER = 1828056235 
	const HIT_KNUCKLES_PLAYER = 2020382007 
	const FLASH_SPYDER = 1237341883 
	const TITLE_MUSIC = 309205993 
	const NOTICE_SPYDER = 1302738403 
	const ATTACK_PILLBUG = 3252579989 
	const NOTICE_PILLBUG = 1980235893 
	const EMPTY_PISTOL_PLAYER = 4149800146 
	const APPEAR_TEXTBOX = 2891465027 
	const WEAPON_PICKUP_PLAYER = 2010675244 
	const DISAPPEAR_TEXTBOX = 476036265 
	const SWING_KNUCKLES_PLAYER = 1198969758 
	const MANIFESTATION_MUSIC = 2930852717 
	const AMMO_PICKUP_PLAYER = 3344761002 
	const DODGE_PLAYER = 942229886 
	const ADVANCE_TEXTBOX = 3852800920 
	const FIRE_SHOTGUN_PLAYER = 1367775454 
	const CHARGE_SPYDER = 282373675 
	const FIRE_TOMMY_PLAYER = 1807675346 
	const HIT_PISTOL_PLAYER = 708461478 
	const CREDITS_MUSIC = 1522595433 
	const CHARGE_BEETLE = 1823915905 
	const ATTACK_MANIFESTATION = 4275276242 
	const ROAR_MANIFESTATION = 1582328950 
	const BACK_MENU = 407919326 
	const DOOR_UNLOCK = 3790708028 
	const SUMMON_MANIFESTATION = 3178172643 
	const HUB_MUSIC = 3751267554 
	const FORWARD_MENU = 338712458 
	const DEATH_ENEMY = 1479467640 
	const DIE_MANIFESTATION = 3227525858 
	const COMBAT_MUSIC = 1932095129 
	const MOVE_MENU = 3289055956 
	const SWING_BATON_PLAYER = 3768797038 
	const SWING_KNIFE_PLAYER = 2160065833 
	const PHONE_RING = 3401439988 

	const _dict = { 
	 "ATTACK BIRD": ATTACK_BIRD,
	 "NOTICE BIRD": NOTICE_BIRD,
	 "SHOOT BIRD": SHOOT_BIRD,
	 "CRASH BEETLE": CRASH_BEETLE,
	 "NOTICE BEETLE": NOTICE_BEETLE,
	 "ATTACK SPYDER": ATTACK_SPYDER,
	 "FIRE PISTOL PLAYER": FIRE_PISTOL_PLAYER,
	 "HIT KNUCKLES PLAYER": HIT_KNUCKLES_PLAYER,
	 "FLASH SPYDER": FLASH_SPYDER,
	 "TITLE MUSIC": TITLE_MUSIC,
	 "NOTICE SPYDER": NOTICE_SPYDER,
	 "ATTACK PILLBUG": ATTACK_PILLBUG,
	 "NOTICE PILLBUG": NOTICE_PILLBUG,
	 "EMPTY PISTOL PLAYER": EMPTY_PISTOL_PLAYER,
	 "APPEAR TEXTBOX": APPEAR_TEXTBOX,
	 "WEAPON PICKUP PLAYER": WEAPON_PICKUP_PLAYER,
	 "DISAPPEAR TEXTBOX": DISAPPEAR_TEXTBOX,
	 "SWING KNUCKLES PLAYER": SWING_KNUCKLES_PLAYER,
	 "MANIFESTATION MUSIC": MANIFESTATION_MUSIC,
	 "AMMO PICKUP PLAYER": AMMO_PICKUP_PLAYER,
	 "DODGE PLAYER": DODGE_PLAYER,
	 "ADVANCE TEXTBOX": ADVANCE_TEXTBOX,
	 "FIRE SHOTGUN PLAYER": FIRE_SHOTGUN_PLAYER,
	 "CHARGE SPYDER": CHARGE_SPYDER,
	 "FIRE TOMMY PLAYER": FIRE_TOMMY_PLAYER,
	 "HIT PISTOL PLAYER": HIT_PISTOL_PLAYER,
	 "CREDITS MUSIC": CREDITS_MUSIC,
	 "CHARGE BEETLE": CHARGE_BEETLE,
	 "ATTACK MANIFESTATION": ATTACK_MANIFESTATION,
	 "ROAR MANIFESTATION": ROAR_MANIFESTATION,
	 "BACK MENU": BACK_MENU,
	 "DOOR UNLOCK": DOOR_UNLOCK,
	 "SUMMON MANIFESTATION": SUMMON_MANIFESTATION,
	 "HUB MUSIC": HUB_MUSIC,
	 "FORWARD MENU": FORWARD_MENU,
	 "DEATH ENEMY": DEATH_ENEMY,
	 "DIE MANIFESTATION": DIE_MANIFESTATION,
	 "COMBAT MUSIC": COMBAT_MUSIC,
	 "MOVE MENU": MOVE_MENU,
	 "SWING BATON PLAYER": SWING_BATON_PLAYER,
	 "SWING KNIFE PLAYER": SWING_KNIFE_PLAYER,
	 "PHONE RING": PHONE_RING
	} 

class STATES:

	class LOWHEALTH:
		const GROUP = 1017222595 

		class STATE:
			const NONE = 748895195 
			const YES = 979470758 
			const NO = 1668749452 

	class GAMEPAUSED:
		const GROUP = 935463065 

		class STATE:
			const NONE = 748895195 
			const NO = 1668749452 
			const YES = 979470758 

	const _dict = { 
		"LOWHEALTH": {
			"GROUP": 1017222595,
			"STATE": {
				"NONE": 748895195,
				"YES": 979470758,
				"NO": 1668749452,
			} 
		}, 
		"GAMEPAUSED": {
			"GROUP": 935463065,
			"STATE": {
				"NONE": 748895195,
				"NO": 1668749452,
				"YES": 979470758
			} 
		} 
	} 

class SWITCHES:

	class HEALTH:
		const GROUP = 3677180323 

		class SWITCH:
			const LOW = 545371365 
			const MAIN = 3161908922 

	const _dict = { 
		"HEALTH": {
			"GROUP": 3677180323,
			"SWITCH": {
				"LOW": 545371365,
				"MAIN": 3161908922
			} 
		} 
	} 

class GAME_PARAMETERS:

	const SS_AIR_SIZE = 3074696722 
	const SS_AIR_FREEFALL = 3002758120 
	const SS_AIR_TIMEOFDAY = 3203397129 
	const SS_AIR_FEAR = 1351367891 
	const SS_AIR_STORM = 3715662592 
	const SS_AIR_MONTH = 2648548617 
	const MUSICFADE = 1614245164 
	const MUSICVOLUME = 2346531308 
	const SS_AIR_PRESENCE = 3847924954 
	const PLAYBACK_RATE = 1524500807 
	const RPM = 796049864 
	const SS_AIR_RPM = 822163944 
	const EFFECTVOLUME = 1087353892 
	const SS_AIR_TURBULENCE = 4160247818 
	const UIVOLUME = 3415057477 
	const SS_AIR_FURY = 1029930033 

	const _dict = { 
	 "SS AIR SIZE": SS_AIR_SIZE,
	 "SS AIR FREEFALL": SS_AIR_FREEFALL,
	 "SS AIR TIMEOFDAY": SS_AIR_TIMEOFDAY,
	 "SS AIR FEAR": SS_AIR_FEAR,
	 "SS AIR STORM": SS_AIR_STORM,
	 "SS AIR MONTH": SS_AIR_MONTH,
	 "MUSICFADE": MUSICFADE,
	 "MUSICVOLUME": MUSICVOLUME,
	 "SS AIR PRESENCE": SS_AIR_PRESENCE,
	 "PLAYBACK RATE": PLAYBACK_RATE,
	 "RPM": RPM,
	 "SS AIR RPM": SS_AIR_RPM,
	 "EFFECTVOLUME": EFFECTVOLUME,
	 "SS AIR TURBULENCE": SS_AIR_TURBULENCE,
	 "UIVOLUME": UIVOLUME,
	 "SS AIR FURY": SS_AIR_FURY
	} 

class TRIGGERS:

	const _dict = {} 

class BANKS:

	const INIT = 1355168291 
	const GAMEPLAY = 89505537 
	const UI = 1551306167 
	const MUSIC = 3991942870 
	const MAIN = 3161908922 

	const _dict = { 
	 "INIT": INIT,
	 "GAMEPLAY": GAMEPLAY,
	 "UI": UI,
	 "MUSIC": MUSIC,
	 "MAIN": MAIN
	} 

class BUSSES:

	const MASTER_AUDIO_BUS = 3803692087 
	const MOTION_FACTORY_BUS = 985987111 

	const _dict = { 
	 "MASTER AUDIO BUS": MASTER_AUDIO_BUS,
	 "MOTION FACTORY BUS": MOTION_FACTORY_BUS
	} 

class AUX_BUSSES:

	const _dict = {} 

class AUDIO_DEVICES:

	const DEFAULT_MOTION_DEVICE = 4230635974 
	const SYSTEM = 3859886410 
	const NO_OUTPUT = 2317455096 

	const _dict = { 
	 "DEFAULT MOTION DEVICE": DEFAULT_MOTION_DEVICE,
	 "SYSTEM": SYSTEM,
	 "NO OUTPUT": NO_OUTPUT
	} 

class EXTERNAL_SOURCES:

	const _dict = {} 

