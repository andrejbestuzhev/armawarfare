/*
  # HEADER #
	Script:			Drones\functions\fn_droneDropBomb.sqf
	Alias:			MyDrones_fnc_droneDropBomb
	Description:	Server-authoritative bombing. Releases ordnance just below the drone with a
					downward velocity (free-fall / bombing run); the drone survives. Limited by
					the drone's remaining bomb count (DRONE_BOMB_COUNT).
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone
	1	[String]: (opt) bomb class. "" => the drone's bomb ammo / DRONE_BOMB_AMMO

  # RETURNED VALUE #
	[Object]: The dropped ordnance (objNull if none left / forwarded)
*/

params [["_drone", objNull, [objNull]], ["_bombClass", "", [""]]];
if (isNull _drone) exitWith { objNull };

if (!isServer) exitWith {
	[_drone, _bombClass] remoteExec ["MyDrones_fnc_droneDropBomb", 2];
	objNull
};

private _count = _drone getVariable ["MyDrones_bombCount", DRONE_BOMB_COUNT];
if (_count <= 0) exitWith { objNull };
_drone setVariable ["MyDrones_bombCount", _count - 1, true];

if (_bombClass isEqualTo "") then {
	_bombClass = _drone getVariable ["MyDrones_bombAmmo", DRONE_BOMB_AMMO];
};

private _p = _drone modelToWorld [0, 0, -1.5];
private _bomb = createVehicle [_bombClass, _p, [], 0, "CAN_COLLIDE"];
_bomb setVelocity [0, 0, -12];

_bomb
