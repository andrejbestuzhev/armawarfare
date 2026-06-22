/*
  # HEADER #
	Script:			Drones\functions\fn_droneAttachPayload.sqf
	Alias:			MyDrones_fnc_droneAttachPayload
	Description:	Visual only. Runs on EVERY machine (createSimpleObject is not networked, so
					each client builds its own copy). Removes any previous payload prop and
					attaches the new one's model under the drone so the ordnance is visible.
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone
	1	[String]: Payload key from DRONE_PAYLOADS

  # RETURNED VALUE #
	[Object]: The attached prop (objNull if none)
*/

params [["_drone", objNull, [objNull]], ["_key", "", [""]], ["_showCount", -1, [0]]];
if (isNull _drone) exitWith { [] };

// Drop any props from a previous payload (stored as an array).
private _old = _drone getVariable ["MyDrones_payloadObj", []];
if (_old isEqualType objNull) then { _old = [_old] };	// tolerate the old single-object form
{ if (!isNull _x) then { detach _x; deleteVehicle _x; }; } forEach _old;
_drone setVariable ["MyDrones_payloadObj", []];

private _idx = DRONE_PAYLOADS findIf { (_x select 0) isEqualTo _key };
if (_idx < 0) exitWith { [] };	// "none"/unknown => stays cleared
(DRONE_PAYLOADS select _idx) params ["_pKey", "_pLabel", "_pAmmo", "_cfgClass", "_modelClass", "", ["_count", 1], ["_ring", 0]];

// Read the model path from the live config so it is always valid on this install.
private _model = getText (configFile >> _cfgClass >> _modelClass >> "model");
if (_model isEqualTo "") exitWith { [] };

// How many models to show: the remaining-round count (clamped to the payload's max), or the
// full count if no override was passed. Ring slots stay fixed (angle by _count) so depleting
// rounds simply removes models from their positions.
private _n = if (_showCount < 0) then { _count } else { _showCount };
_n = (_n min _count) max 0;

DRONE_PAYLOAD_OFFSET params ["_ox", "_oy", "_oz"];
private _objs = [];
for "_i" from 0 to (_n - 1) do {
	// Single model sits at the centre; multiple are spread evenly around a ring.
	private _ang = if (_count > 1) then { _i * (360 / _count) } else { 0 };
	private _pos = [_ox + (_ring * sin _ang), _oy + (_ring * cos _ang), _oz];
	private _obj = createSimpleObject [_model, [0, 0, 0], false];
	_obj attachTo [_drone, _pos];
	_objs pushBack _obj;
};
_drone setVariable ["MyDrones_payloadObj", _objs];

_objs
