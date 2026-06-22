/*
  # HEADER #
	Script:			Drones\functions\fn_droneSetBomb.sqf
	Alias:			MyDrones_fnc_droneSetBomb
	Description:	Client-local. Arms (or clears) a drone's payload, charging BECTI funds.
					Arming any payload other than "none" costs DRONE_BOMB_COST (or
					DRONE_BOMB_COST_DEBUG when CTI_DEBUG is on). "none" is free. The drone must
					be on the ground. The actual payload change is server-authoritative
					(droneSetPayload).
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone
	1	[String]: Payload key ("none" / "grenade" / "satchel" / "rpg")

  # RETURNED VALUE #
	[Bool]: true if applied
*/

params [["_drone", objNull, [objNull]], ["_choice", "none", [""]]];
if (isNull _drone) exitWith { false };

if (!(_drone call DRONE_FNC_ONGROUND)) exitWith {
	hint "The drone must be on the ground to change its payload.";
	false
};

// "none" is free: strip the payload (allowed on any drone).
if (_choice in ["", "none"]) exitWith {
	[_drone, "none"] call MyDrones_fnc_droneSetPayload;
	hint "Drone payload removed.";
	true
};

// Arming a real payload is restricted to the AR-2 Darter.
if ((DRONE_ALLOWED_TYPES findIf { _drone isKindOf _x }) < 0) exitWith {
	hint "Only the AR-2 Darter can carry a payload.";
	false
};

private _cost = if (call DRONE_FNC_DEBUGPRICE) then { DRONE_BOMB_COST_DEBUG } else { DRONE_BOMB_COST };

// Charge BECTI funds when the economy is present (degrades to free in non-BECTI missions).
private _hasEconomy = !isNil "CTI_CL_FNC_GetPlayerFunds" && {!isNil "CTI_CL_FNC_ChangePlayerFunds"};
private _funds = if (_hasEconomy) then { call CTI_CL_FNC_GetPlayerFunds } else { 1e9 };

// Affordability guard at function scope (so it actually aborts).
if (_hasEconomy && {_funds < _cost}) exitWith {
	hint format ["Not enough funds: need $%1, you have $%2.", _cost, floor _funds];
	false
};

if (_hasEconomy) then { -(_cost) call CTI_CL_FNC_ChangePlayerFunds; };

[_drone, _choice] call MyDrones_fnc_droneSetPayload;
hint format ["Drone armed: %1  (-$%2)", _choice, _cost];
true
