/*
  # HEADER #
	Script:			Drones\functions\fn_droneSetBombMenu.sqf
	Alias:			MyDrones_fnc_droneSetBombMenu
	Description:	Client-local. Opens the "Set bomb" popup for the given drone. The drone must
					be on the ground (rearming in the air is not allowed). The dialog buttons
					call MyDrones_fnc_droneSetBomb with the chosen payload key.
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone to arm

  # RETURNED VALUE #
	[Nothing]
*/

params [["_drone", objNull, [objNull]]];
if (isNull _drone) exitWith {};

if ((DRONE_ALLOWED_TYPES findIf { _drone isKindOf _x }) < 0) exitWith {
	hint "Only the AR-2 Darter can carry a payload.";
};

if (!(_drone call DRONE_FNC_ONGROUND)) exitWith {
	hint "The drone must be on the ground to change its payload.";
};

// Remember which drone the dialog acts on, then open it.
MyDrones_setBombTarget = _drone;
createDialog "MyDrones_SetBombDialog";

// Show the current price in the title (debug = cheap).
private _cost = if (call DRONE_FNC_DEBUGPRICE) then { DRONE_BOMB_COST_DEBUG } else { DRONE_BOMB_COST };
private _disp = findDisplay 9100;
if (!isNull _disp) then {
	(_disp displayCtrl 9101) ctrlSetText format ["Set drone bomb   (cost: $%1)", _cost];
};
