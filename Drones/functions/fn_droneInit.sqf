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
// MyDrones_bombCount is owned by droneSetPayload (set/refilled when a payload is armed).
_drone setVariable ["MyDrones_detonated", false, true];
// Armed => a hard ram detonates the warhead. Default true (matches reference kamikaze-by-ram).
if (isNil { _drone getVariable "MyDrones_armed" }) then {
	_drone setVariable ["MyDrones_armed", true, true];
};

// --- Apply the visible payload (default until the operator changes it) ---------
if (isNil { _drone getVariable "MyDrones_payload" }) then {
	[_drone, DRONE_DEFAULT_PAYLOAD] call MyDrones_fnc_droneSetPayload;
} else {
	// Re-init (e.g. respawn): rebuild the visible model for the stored payload.
	[_drone, _drone getVariable ["MyDrones_payload", DRONE_DEFAULT_PAYLOAD]] call MyDrones_fnc_droneSetPayload;
};

// --- Context-menu actions on the drone itself (visible to nearby players) ------
[_drone] remoteExec ["MyDrones_fnc_droneAddDroneActions", 0, format ["MyDrones_dacts_%1", netId _drone]];

// --- Impact arming: only after the drone has actually left the ground ----------
// Resolves the conflict: a drone resting on the ground never detonates; a drone that
// has flown and then strikes the ground/target at speed does. The latch sets once and
// the loop exits (cheap, short-lived).
_drone setVariable ["MyDrones_airborne", false, true];
[_drone] spawn {
	params ["_drone"];
	waitUntil {
		sleep 0.5;
		isNull _drone || !alive _drone || {((getPosATL _drone) select 2) > DRONE_AIRBORNE_HEIGHT}
	};
	if (!isNull _drone && {alive _drone}) then {
		_drone setVariable ["MyDrones_airborne", true, true];
	};
};

// --- Detonate on a hard impact (kamikaze contact trigger) ---------------------
_drone addEventHandler ["EpeContactStart", {
	params ["_drone"];
	if (_drone getVariable ["MyDrones_detonated", false]) exitWith {};
	if (!(_drone getVariable ["MyDrones_armed", true])) exitWith {};
	if (!(_drone getVariable ["MyDrones_airborne", false])) exitWith {};		// still grounded -> ignore
	if (vectorMagnitude velocity _drone < DRONE_RAM_MIN_SPEED) exitWith {};	// soft contact -> ignore
	[_drone, _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO]] call MyDrones_fnc_droneKamikaze;
}];

// --- Optionally detonate the warhead when the drone is destroyed --------------
if (DRONE_EXPLODE_ON_DEATH) then {
	_drone addEventHandler ["Killed", {
		params ["_drone"];
		[_drone, _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO]] call MyDrones_fnc_droneKamikaze;
	}];
};

// --- Remove the visible payload model everywhere when the drone dies ----------
_drone addEventHandler ["Killed", {
	params ["_drone"];
	private _jip = format ["MyDrones_payload_%1", netId _drone];
	remoteExec ["", _jip];									// drop the JIP attach message
	[_drone, ""] remoteExec ["MyDrones_fnc_droneAttachPayload", 0];	// delete props on all machines
	remoteExec ["", format ["MyDrones_dacts_%1", netId _drone]];	// drop the JIP drone-actions message
}];

// --- Re-apply the framework after a respawn (respawn-module compatibility) ----
_drone addEventHandler ["Respawn", {
	params ["_drone"];
	_drone setVariable ["MyDrones_inited", false, true];
	[_drone] call MyDrones_fnc_droneInit;
}];

_drone
