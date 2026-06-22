/*
  # HEADER #
	Script:			Drones\functions\fn_droneSetPayload.sqf
	Alias:			MyDrones_fnc_droneSetPayload
	Description:	Server-authoritative payload setter. Resolves the payload key against
					DRONE_PAYLOADS, stores the detonation ammo + payload key on the drone as
					PUBLIC variables, and broadcasts the VISIBLE model attachment to every
					machine (JIP-safe, keyed by the drone's netId so re-selecting replaces it).
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone
	1	[String]: Payload key from DRONE_PAYLOADS (e.g. "grenade", "satchel", "rpg")

  # RETURNED VALUE #
	[Bool]: true if the payload was applied
*/

params [["_drone", objNull, [objNull]], ["_key", "", [""]]];
if (isNull _drone) exitWith { false };

if (!isServer) exitWith {
	[_drone, _key] remoteExec ["MyDrones_fnc_droneSetPayload", 2];
	false
};

private _jip = format ["MyDrones_payload_%1", netId _drone];

// "none" / empty => strip the payload entirely (no bomb, nothing to detonate or drop).
if (_key in ["", "none"]) exitWith {
	_drone setVariable ["MyDrones_payload", "none", true];
	_drone setVariable ["MyDrones_ammo", "", true];
	_drone setVariable ["MyDrones_canDetonate", false, true];
	_drone setVariable ["MyDrones_bombCount", 0, true];
	remoteExec ["", _jip];
	[_drone, "none"] remoteExec ["MyDrones_fnc_droneAttachPayload", 0];
	true
};

private _idx = DRONE_PAYLOADS findIf { (_x select 0) isEqualTo _key };
if (_idx < 0) exitWith { false };
(DRONE_PAYLOADS select _idx) params ["_pKey", "_pLabel", "_pAmmo", "", "", ["_pCanDet", false], ["_pCount", 1]];

_drone setVariable ["MyDrones_payload", _pKey, true];
_drone setVariable ["MyDrones_ammo", _pAmmo, true];
_drone setVariable ["MyDrones_canDetonate", _pCanDet, true];	// gates the "Detonate bomb" action
_drone setVariable ["MyDrones_bombCount", _pCount, true];		// drops available = number of rounds carried

// Build/refresh the visible models on every machine (one per remaining round). JIP id keyed to
// this drone so a late joiner only ever replays the latest payload (and it is dropped on death).
[_drone, _pKey, _pCount] remoteExec ["MyDrones_fnc_droneAttachPayload", 0, _jip];

true
