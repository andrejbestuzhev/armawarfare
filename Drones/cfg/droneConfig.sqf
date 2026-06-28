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
DRONE_DEFAULT_AMMO		= "SatchelCharge_Remote_Ammo";	// fallback warhead if no payload is set
DRONE_BOMB_COUNT		= 1;					// number of drops a drone carries (per armed payload)
DRONE_DROP_VELOCITY		= -12;					// m/s downward velocity given to a dropped bomb
DRONE_DETONATE_DELAY	= 0.05;					// s: delay before the warhead goes off (kept short so rockets blow in place)
DRONE_EXPLODE_ON_DEATH	= true;					// also detonate the warhead when the drone is killed

// --- Economy (BECTI funds) ----------------------------------------------------
DRONE_BOMB_COST			= 500;					// $ to arm a payload in PROD (anything except "none")
DRONE_BOMB_COST_DEBUG	= 1;					// $ to arm a payload in DEBUG
// Debug pricing follows the mission's real debug switch CTI_PRICES_DEBUG (see
// Common\Config\Prices.sqf), with CTI_DEBUG as a fallback. Read at runtime so load order
// never matters. Returns true => arming costs DRONE_BOMB_COST_DEBUG.
DRONE_FNC_DEBUGPRICE = {
	(missionNamespace getVariable ["CTI_PRICES_DEBUG", false]) || { missionNamespace getVariable ["CTI_DEBUG", false] }
};

// --- Impact arming (resolves the "resting on ground vs. striking ground" conflict) ---
// A drone only detonates on contact once it has actually been airborne AND it hits
// something at/above DRONE_RAM_MIN_SPEED. A drone simply sitting on the ground (or
// landing gently) never trips the contact trigger; a dive/crash into the ground does.
DRONE_RAM_MIN_SPEED		= 8;					// m/s: minimum impact speed for a ram to detonate
DRONE_AIRBORNE_HEIGHT	= 3;					// m: height above ground that counts as "took off" (arms impact)

// --- Payloads (visible suspended ordnance) ------------------------------------
// Each payload: [key, label, detonation CfgAmmo, modelConfig, modelClass, canDetonate, count, ring]
//   detonation CfgAmmo  - what is spawned + setDamage'd to create the blast
//   modelConfig/Class   - where to read the VISIBLE model from (read at runtime so the
//                         p3d path is always valid on the installed game)
//   canDetonate         - true => the "Detonate bomb" command works (satchel/RPG-style).
//                         false => drop-only (a grenade is thrown, not remote-detonated).
//   count               - number of visible models shown on the drone
//   ring                - radius (m) of the circle the models are arranged on (0 => single, centred)
DRONE_PAYLOADS = [
	["grenade",	"Frag grenade",		"GrenadeHand",					"CfgMagazines",	"HandGrenade",				false,	6,	0.15],
	["satchel",	"Satchel charge",	"SatchelCharge_Remote_Ammo",	"CfgMagazines",	"SatchelCharge_Remote_Mag",	true,	1,	0],
	["rpg",		"RPG rocket",		"R_PG32V_F",					"CfgAmmo",		"R_PG32V_F",				true,	1,	0]
];
DRONE_DEFAULT_PAYLOAD	= "none";				// FPV drones start empty (player buys via "Set bomb")
DRONE_AUTO_PAYLOAD		= "satchel";			// payload given to autonomous drones on spawn
DRONE_PAYLOAD_OFFSET	= [0, 0, -0.35];		// model attach offset under the drone
// Only these UAV types may be armed. UAV_01_base_F is the AR-2 Darter base, so this catches
// every faction variant (B_/O_/I_UAV_01_F); explicit classes listed too as a safety net.
DRONE_ALLOWED_TYPES		= ["UAV_01_base_F", "B_UAV_01_F", "O_UAV_01_F", "I_UAV_01_F"];

// Robust "is this drone on the ground?" test (isTouchingGround can read false for UAVs, so we
// also accept a low height above terrain). Used to gate rearming. Call: _drone call DRONE_FNC_ONGROUND
DRONE_FNC_ONGROUND = { isTouchingGround _this || { ((getPosATL _this) select 2) < 1.5 } };

DRONE_SETBOMB_RANGE	= 10;	// m: how close the player must be to a grounded drone to arm it (≈ connect range)

// Nearest armable drone (allowed type, on the ground) within DRONE_SETBOMB_RANGE of a unit, or
// objNull. This is what makes "Set bomb" appear for the player standing next to the drone.
// Call: _player call DRONE_FNC_NEARBYDRONE
DRONE_FNC_NEARBYDRONE = {
	private _list = (nearestObjects [_this, DRONE_ALLOWED_TYPES, DRONE_SETBOMB_RANGE]) select {
		alive _x && { _x call DRONE_FNC_ONGROUND }
	};
	if (count _list > 0) then { _list select 0 } else { objNull }
};

// --- Autonomous (suicide) behaviour ------------------------------------------
DRONE_BLAST_RANGE		= 6;					// m: auto-detonation distance to the target
DRONE_DETECT_RANGE		= 600;					// m: target search radius
DRONE_TARGET_SIDES		= [east, resistance];	// sides an autonomous drone will hunt
DRONE_DIVE_SPEED		= 35;					// m/s dive speed during the attack run
DRONE_DIVE_HEIGHT		= 80;					// m: loiter height while searching for a target
DRONE_HUNT_TICK			= 0.1;					// s: steering update interval during a dive

