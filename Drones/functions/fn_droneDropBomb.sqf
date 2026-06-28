/*
  # HEADER #
	Script:			Drones\functions\fn_droneDropBomb.sqf
	Alias:			MyDrones_fnc_droneDropBomb
	Description:	Server-authoritative bombing. Releases the drone's CURRENTLY SELECTED payload
					just below it with a downward velocity; the round falls and detonates when it
					reaches the ground (bombing run). The drone survives. The carried payload is
					consumed: its visible model is removed and its count decremented.
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone

  # RETURNED VALUE #
	[Object]: The dropped ordnance (objNull if none left / forwarded)
*/

params [["_drone", objNull, [objNull]]];
if (isNull _drone) exitWith { objNull };

if (!isServer) exitWith {
	[_drone] remoteExec ["MyDrones_fnc_droneDropBomb", 2];
	objNull
};

// One drop = one round. A grenade payload carries several, so drops repeat until empty.
private _count = _drone getVariable ["MyDrones_bombCount", 0];
if (_count <= 0) exitWith { objNull };
private _remaining = _count - 1;
_drone setVariable ["MyDrones_bombCount", _remaining, true];

private _ammoClass = _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO];
private _payload = _drone getVariable ["MyDrones_payload", "none"];
private _jip = format ["MyDrones_payload_%1", netId _drone];

// Drop one round below the drone.
private _p = _drone modelToWorld [0, 0, -1.5];
private _bomb = _ammoClass createVehicle _p;
_bomb setVelocity [0, 0, DRONE_DROP_VELOCITY];

// Update the visible models / payload state.
if (_remaining > 0) then {
	// Still carrying rounds: redraw the ring with the remaining count.
	[_drone, _payload, _remaining] remoteExec ["MyDrones_fnc_droneAttachPayload", 0, _jip];
} else {
	// Last round gone: strip the payload entirely.
	remoteExec ["", _jip];
	[_drone, "none"] remoteExec ["MyDrones_fnc_droneAttachPayload", 0];
	_drone setVariable ["MyDrones_payload", "none", true];
	_drone setVariable ["MyDrones_ammo", "", true];
	_drone setVariable ["MyDrones_canDetonate", false, true];
};

// Detonate when it reaches the ground (charge/mine types do not self-explode, so force it).
[_bomb] spawn {
	params ["_b"];
	private _t = 0;
	waitUntil {
		sleep 0.05;
		_t = _t + 0.05;
		(isNull _b) || {!alive _b} || {((getPosATL _b) select 2) < 0.5} || {_t > 15}
	};
	if (!isNull _b && {alive _b}) then { _b setDamage 1; };
};

_bomb
