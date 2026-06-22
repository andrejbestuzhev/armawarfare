/*
  # HEADER #
	Script:			Drones\functions\fn_droneAddActions.sqf
	Alias:			MyDrones_fnc_droneAddActions
	Description:	Client-local. Adds the player's "Set bomb" action, which appears when the
					player stands next to a grounded AR-2 (same context as the vanilla Connect),
					and opens the arming popup for that drone.
					Also runs a light monitor that framework-inits whatever drone the player
					connects to (covers vanilla backpack-assembled Darters not placed in Eden).
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The player

  # RETURNED VALUE #
	[Nothing]
*/

params [["_unit", player, [objNull]]];
if (isNull _unit) exitWith {};
if (_unit getVariable ["MyDrones_actionsAdded", false]) exitWith {};
_unit setVariable ["MyDrones_actionsAdded", true];

// --- Set bomb (rearm) — PLAYER action, near a grounded AR-2 (same context as "Connect") ---
// Detonate/Drop are NOT here; they live on the drone's own context menu (used in flight).
_unit addAction [
	"<t color='#88ccff'>Set bomb...</t>",
	{
		params ["_target", "_caller"];
		private _drone = _caller call DRONE_FNC_NEARBYDRONE;
		if (isNull _drone) exitWith {};
		[_drone] call MyDrones_fnc_droneSetBombMenu;
	},
	nil, 1.6, false, true, "",
	"!isNull (_this call DRONE_FNC_NEARBYDRONE)", 10
];

// --- Init-on-connect monitor --------------------------------------------------
// Ensures any drone the player connects to (incl. backpack-assembled Darters) gets the
// framework EHs/state. droneInit is idempotent and runs server-side via remoteExec.
[_unit] spawn {
	params ["_unit"];
	private _last = objNull;
	while { true } do {
		private _uav = getConnectedUAV _unit;
		if (!isNull _uav && {_uav != _last}) then {
			_last = _uav;
			if (!(_uav getVariable ["MyDrones_inited", false])) then {
				[_uav] remoteExec ["MyDrones_fnc_droneInit", 2];
			};
		};
		if (isNull _uav) then { _last = objNull; };
		sleep 2;
	};
};
