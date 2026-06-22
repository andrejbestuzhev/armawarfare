/*
  # HEADER #
	Script:			Drones\functions\fn_droneSelectAmmo.sqf
	Alias:			MyDrones_fnc_droneSelectAmmo
	Description:	Cycles the warhead the connected drone will use (FPV terminal ammo selection,
					acceptance output §9.2). The choice is stored on the drone as a PUBLIC variable
					so the server's kamikaze logic reads the same value.
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The player operating the terminal

  # RETURNED VALUE #
	[String]: The newly selected warhead class ("" if no drone connected)
*/

params [["_unit", player, [objNull]]];
private _drone = getConnectedUAV _unit;
if (isNull _drone) exitWith { "" };

private _list = DRONE_AMMO_LIST;
private _current = _drone getVariable ["MyDrones_ammo", (_list select 0 select 0)];
private _idx = _list findIf { (_x select 0) isEqualTo _current };
_idx = (_idx + 1) mod (count _list);
(_list select _idx) params ["_class", "_label"];

// Broadcast the choice on the drone (it is local to the server, not this client).
_drone setVariable ["MyDrones_ammo", _class, true];

hint format ["Drone warhead set to:\n%1", _label];
_class
