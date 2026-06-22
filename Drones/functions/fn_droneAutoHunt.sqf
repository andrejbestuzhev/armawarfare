/*
  # HEADER #
	Script:			Drones\functions\fn_droneAutoHunt.sqf
	Alias:			MyDrones_fnc_droneAutoHunt
	Description:	Autonomous suicide behaviour (server only). The drone loiters at altitude,
					acquires the nearest valid enemy within DRONE_DETECT_RANGE, dives toward it
					by steering its velocity, and detonates within DRONE_BLAST_RANGE (or on a
					hard ram, via the EpeContact EH in droneInit).
	Author:			Drone framework

  # PARAMETERS #
	0	[Object]: The drone

  # RETURNED VALUE #
	[Nothing]
*/

params [["_drone", objNull, [objNull]]];
if (isNull _drone) exitWith {};
if (!isServer) exitWith {};	// autonomous logic is server-authoritative

_drone setVariable ["MyDrones_autonomous", true, true];
if (_drone getVariable ["MyDrones_hunting", false]) exitWith {};
_drone setVariable ["MyDrones_hunting", true, true];

// Make sure the framework EHs/state are present.
[_drone] call MyDrones_fnc_droneInit;

[_drone] spawn {
	params ["_drone"];
	private _target = objNull;

	while { alive _drone && !(_drone getVariable ["MyDrones_detonated", false]) } do {

		// (Re)acquire the nearest valid enemy.
		if (isNull _target || {!alive _target}) then {
			private _best = objNull;
			private _bestDist = DRONE_DETECT_RANGE;
			{
				private _s = if (_x isKindOf "Man") then { side group _x } else { side _x };
				if (alive _x && {_s in DRONE_TARGET_SIDES}) then {
					private _d = _drone distance _x;
					if (_d < _bestDist) then { _bestDist = _d; _best = _x; };
				};
			} forEach (_drone nearEntities [["Man", "Car", "Tank", "Truck", "Air", "Ship"], DRONE_DETECT_RANGE]);
			_target = _best;
		};

		if (isNull _target) then {
			// Loiter until something shows up.
			_drone flyInHeight DRONE_DIVE_HEIGHT;
			sleep 1;
		} else {
			private _dir = (getPosASL _target) vectorDiff (getPosASL _drone);
			private _dist = vectorMagnitude _dir;

			if (_dist <= DRONE_BLAST_RANGE) exitWith {
				[_drone, _drone getVariable ["MyDrones_ammo", DRONE_DEFAULT_AMMO]] call MyDrones_fnc_droneKamikaze;
			};

			// Steer straight at the target at dive speed (loitering-munition style).
			_drone setVariable ["MyDrones_armed", true, true];
			private _unit = vectorNormalized _dir;
			_drone setVelocity (_unit vectorMultiply DRONE_DIVE_SPEED);
			_drone setVectorDir _unit;
			sleep DRONE_HUNT_TICK;
		};
	};

	_drone setVariable ["MyDrones_hunting", false, true];
};
