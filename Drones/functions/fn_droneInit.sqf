/*
  # HEADER #
	Script:			Drones\functions\fn_droneInit.sqf
	Alias:			MyDrones_fnc_droneInit
	Description:	Per-drone setup: default variables + event handlers. Idempotent and
					re-appliable after respawn. Runs where the drone is LOCAL (the server
					for AI UAVs); forwards itself there otherwise.
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone to initialise

  # RETURNED VALUE #
	[Object]: The drone
*/

params [["_drone", objNull, [objNull]]];
if (isNull _drone) exitWith { objNull };

// EHs / state must live on the machine where the drone is local.
if (!local _drone) exitWith {
	[_drone] remoteExec ["MyDrones_fnc_droneInit", _drone];
	_drone
};

if (_drone getVariable ["MyDrones_inited", false]) exitWith { _drone };
_drone setVariable ["MyDrones_inited", true, true];
_drone setVariable ["MyDrones_managed", true, true];

// --- Default state (broadcast so client actions can read it) ------------------
if (isNil { _drone getVariable "MyDrones_ammo" }) then {
	_drone setVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO, true];
};
_drone setVariable ["MyDrones_bombAmmo", DRONE_BOMB_AMMO, true];
_drone setVariable ["MyDrones_bombCount", DRONE_BOMB_COUNT, true];
_drone setVariable ["MyDrones_detonated", false, true];
// Armed => a hard ram detonates the warhead. Default true (matches reference kamikaze-by-ram).
if (isNil { _drone getVariable "MyDrones_armed" }) then {
	_drone setVariable ["MyDrones_armed", true, true];
};

// --- Detonate on a hard impact (kamikaze contact trigger) ---------------------
_drone addEventHandler ["EpeContactStart", {
	params ["_drone"];
	if (_drone getVariable ["MyDrones_detonated", false]) exitWith {};
	if (!(_drone getVariable ["MyDrones_armed", true])) exitWith {};
	if (vectorMagnitude velocity _drone < DRONE_RAM_MIN_SPEED) exitWith {};	// ignore soft contact
	[_drone, _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO]] call MyDrones_fnc_droneKamikaze;
}];

// --- Optionally detonate the warhead when the drone is destroyed --------------
if (DRONE_EXPLODE_ON_DEATH) then {
	_drone addEventHandler ["Killed", {
		params ["_drone"];
		[_drone, _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO]] call MyDrones_fnc_droneKamikaze;
	}];
};

// --- Re-apply the framework after a respawn (respawn-module compatibility) ----
_drone addEventHandler ["Respawn", {
	params ["_drone"];
	_drone setVariable ["MyDrones_inited", false, true];
	[_drone] call MyDrones_fnc_droneInit;
}];

_drone
