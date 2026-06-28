/*
  # HEADER #
	Script:			Drones\functions\fn_droneAddDroneActions.sqf
	Alias:			MyDrones_fnc_droneAddDroneActions
	Description:	Adds the Detonate / Drop actions to the DRONE object's own context menu (shown
					to the operator while piloting and to players near the drone). Used IN THE AIR
					over a target — not gated to the ground. Runs on every machine with an
					interface (broadcast from droneInit, JIP-safe). Idempotent via a LOCAL flag.
					(Arming — "Set bomb" — is a separate PLAYER action: see fn_droneAddActions.)
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone

  # RETURNED VALUE #
	[Nothing]
*/

params [["_drone", objNull, [objNull]]];
if (isNull _drone) exitWith {};
if (!hasInterface) exitWith {};
if (_drone getVariable ["MyDrones_droneActionsAdded", false]) exitWith {};
_drone setVariable ["MyDrones_droneActionsAdded", true];	// LOCAL flag (not broadcast)

// Detonate/Drop live on the DRONE menu and are used IN THE AIR (not gated to the ground).
// Set bomb is NOT here — it is a player action near the grounded drone (see fn_droneAddActions).

// Detonate the carried bomb — satchel/RPG only.
_drone addAction [
	"<t color='#ff3333'>Detonate bomb</t>",
	{ params ["_target"]; [_target] remoteExec ["MyDrones_fnc_droneKamikaze", 2]; },
	nil, 1.5, true, true, "",
	"alive _target && {_target getVariable ['MyDrones_canDetonate', false]}", 60
];

// Drop the carried bomb.
_drone addAction [
	"<t color='#ffaa00'>Drop bomb</t>",
	{ params ["_target"]; [_target] remoteExec ["MyDrones_fnc_droneDropBomb", 2]; },
	nil, 1.4, true, true, "",
	"alive _target && {(_target getVariable ['MyDrones_bombCount', 0]) > 0}", 60
];
