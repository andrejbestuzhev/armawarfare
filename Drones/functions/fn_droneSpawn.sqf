/*
  # HEADER #
	Script:			Drones\functions\fn_droneSpawn.sqf
	Alias:			MyDrones_fnc_droneSpawn
	Description:	Dynamic spawn (server only). Creates a UAV, framework-inits it and either:
					- autonomous: gives it an AI operator and starts the hunt loop, or
					- player:     connects the given player's UAV terminal so they fly it FPV.
					Vanilla default class is the AR-2 Darter (B_UAV_01_F) — no addon dependency.
	Author:			Drone framework

  # PARAMETERS #
	0	[String]: (opt) UAV class             — default "B_UAV_01_F"
	1	[Array]:  position [x,y,z]
	2	[Side]:   (opt) owning side            — default west
	3	[Bool]:   (opt) autonomous?            — default false
	4	[Object]: (opt) player to hand FPV control to (non-autonomous) — default objNull

  # RETURNED VALUE #
	[Object]: The spawned drone (objNull if forwarded from a client)
*/

params [
	["_class", "B_UAV_01_F", [""]],
	["_pos", [0,0,0], [[]], [3]],
	["_side", west, [west]],
	["_autonomous", false, [false]],
	["_owner", objNull, [objNull]]
];

if (!isServer) exitWith {
	[_class, _pos, _side, _autonomous, _owner] remoteExec ["MyDrones_fnc_droneSpawn", 2];
	objNull
};

private _grp = createGroup [_side, true];
private _drone = createVehicle [_class, _pos, [], 0, "FLY"];
_drone setPosATL [_pos select 0, _pos select 1, (DRONE_DIVE_HEIGHT max 50)];

if (_autonomous) then {
	// Needs an AI crew to fly itself.
	createVehicleCrew _drone;
	(crew _drone) joinSilent _grp;
	[_drone] call MyDrones_fnc_droneInit;
	[_drone] call MyDrones_fnc_droneAutoHunt;
} else {
	[_drone] call MyDrones_fnc_droneInit;
	// Hand FPV control to a player's terminal (must run where the terminal holder is local).
	if (!isNull _owner) then {
		[_owner, _drone] remoteExec ["connectTerminalToUAV", _owner];
	};
};

_drone
