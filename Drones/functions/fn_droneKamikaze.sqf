/*
  # HEADER #
	Script:			Drones\functions\fn_droneKamikaze.sqf
	Alias:			MyDrones_fnc_droneKamikaze
	Description:	Server-authoritative detonation. Spawns the warhead at the drone, detonates
					it after a short delay and destroys the drone. Single-shot guarded so a
					client request, a contact EH and the Killed EH can never stack explosions.
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone
	1	[String]: (opt) warhead class. "" => use the drone's selected ammo / DRONE_DEFAULT_AMMO
	2	[Number]: (opt) detonation delay. <0 => DRONE_DETONATE_DELAY

  # RETURNED VALUE #
	[Nothing]
*/

params [["_drone", objNull, [objNull]], ["_ammoClass", "", [""]], ["_delay", -1, [0]]];
if (isNull _drone) exitWith {};

// Detonation is decided on the server to avoid duplicate blasts across clients.
if (!isServer) exitWith {
	[_drone, _ammoClass, _delay] remoteExec ["MyDrones_fnc_droneKamikaze", 2];
};

// Single-shot guard.
if (_drone getVariable ["MyDrones_detonated", false]) exitWith {};
_drone setVariable ["MyDrones_detonated", true, true];

if (_ammoClass isEqualTo "") then {
	_ammoClass = _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO];
};
if (_delay < 0) then { _delay = DRONE_DETONATE_DELAY; };

// No payload armed -> just destroy the drone, nothing to detonate.
if (_ammoClass isEqualTo "") exitWith { _drone setDamage 1; };

private _pos = getPosATL _drone;
private _ammo = _ammoClass createVehicle _pos;
// Rockets/missiles are created with launch velocity and would fly away; pin them so the
// warhead detonates in place. Charges/mines just sit until setDamage anyway.
_ammo setVelocity [0, 0, 0];

[_ammo, _delay max 0.0] spawn {
	params ["_a", "_d"];
	if (_d > 0) then { sleep _d };
	if (!isNull _a) then {
		_a setVelocity [0, 0, 0];
		_a setDamage 1;
	};
};

_drone setDamage 1;
