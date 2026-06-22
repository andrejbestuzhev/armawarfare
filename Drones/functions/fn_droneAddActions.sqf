/*
  # HEADER #
	Script:			Drones\functions\fn_droneAddActions.sqf
	Alias:			MyDrones_fnc_droneAddActions
	Description:	Client-local. Attaches the FPV scroll actions to the player. They are visible
					only while a UAV terminal is connected (getConnectedUAV). All actions are
					server-forwarded (remoteExec) so the server stays authoritative.
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

// --- Detonate the connected drone --------------------------------------------
_unit addAction [
	"<t color='#ff3333'>Detonate drone</t>",
	{
		params ["_target", "_caller"];
		private _drone = getConnectedUAV _caller;
		if (isNull _drone) exitWith {};
		[_drone, _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO]] remoteExec ["MyDrones_fnc_droneKamikaze", 2];
	},
	nil, 1.5, false, true, "",
	"!isNull (getConnectedUAV _this)", 10
];

// --- Drop the carried ordnance -----------------------------------------------
_unit addAction [
	"<t color='#ffaa00'>Drop bomb</t>",
	{
		params ["_target", "_caller"];
		private _drone = getConnectedUAV _caller;
		if (isNull _drone) exitWith {};
		[_drone, _drone getVariable ["MyDrones_bombAmmo", DRONE_BOMB_AMMO]] remoteExec ["MyDrones_fnc_droneDropBomb", 2];
	},
	nil, 1.4, false, true, "",
	"!isNull (getConnectedUAV _this) && {((getConnectedUAV _this) getVariable ['MyDrones_bombCount', DRONE_BOMB_COUNT]) > 0}", 10
];

// --- Cycle the warhead via the UAV terminal ----------------------------------
_unit addAction [
	"<t color='#88ccff'>Drone ammo: cycle warhead</t>",
	{ [_this select 1] call MyDrones_fnc_droneSelectAmmo; },
	nil, 1.3, false, true, "",
	"!isNull (getConnectedUAV _this)", 10
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
