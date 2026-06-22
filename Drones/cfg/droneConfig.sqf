/*
  # HEADER #
	Script:			Drones\cfg\droneConfig.sqf
	Description:	Centralised settings for the FPV / suicide-drone framework.
					Loaded on EVERY machine by MyDrones_fnc_droneBootstrap (CfgFunctions postInit).
	Author:			Drone framework

  # NOTES #
	- All tunables live here. Change them in this one file only (acceptance criterion §7).
	- Values are plain globals with the distinctive DRONE_ prefix so the *_fnc_* helpers
	  can read them directly (matches the reference TZ §6).
	- Classes are vanilla (no addon dependency). Swap them here for modded ordnance.
*/

// --- Warheads -----------------------------------------------------------------
DRONE_DEFAULT_AMMO		= "Bo_GBU12_LGB";		// kamikaze warhead detonated at the drone
DRONE_BOMB_AMMO			= "ATMine_Range_Ammo";	// ordnance released in bombing mode
DRONE_BOMB_COUNT		= 1;					// number of drops a drone carries
DRONE_DETONATE_DELAY	= 0.3;					// s: delay before the warhead goes off (reference pattern)
DRONE_EXPLODE_ON_DEATH	= true;					// also detonate the warhead when the drone is killed
DRONE_RAM_MIN_SPEED		= 8;					// m/s: minimum impact speed for a ram to detonate (ignores soft landings)

// --- Autonomous (suicide) behaviour ------------------------------------------
DRONE_BLAST_RANGE		= 6;					// m: auto-detonation distance to the target
DRONE_DETECT_RANGE		= 600;					// m: target search radius
DRONE_TARGET_SIDES		= [east, resistance];	// sides an autonomous drone will hunt
DRONE_DIVE_SPEED		= 35;					// m/s dive speed during the attack run
DRONE_DIVE_HEIGHT		= 80;					// m: loiter height while searching for a target
DRONE_HUNT_TICK			= 0.1;					// s: steering update interval during a dive

// --- FPV terminal warhead menu ------------------------------------------------
// Offered through the "Drone ammo" scroll action while a UAV terminal is connected.
// [ammo CfgAmmo/CfgMagazines class, human label]
DRONE_AMMO_LIST = [
	["Bo_GBU12_LGB",				"GBU-12 (heavy bomb)"],
	["R_PG32V_F",					"RPG warhead"],
	["ATMine_Range_Ammo",			"AT charge"],
	["SatchelCharge_Remote_Ammo",	"Satchel charge"]
];
