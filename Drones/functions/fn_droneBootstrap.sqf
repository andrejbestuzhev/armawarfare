/*
  # HEADER #
	Script:			Drones\functions\fn_droneBootstrap.sqf
	Alias:			MyDrones_fnc_droneBootstrap
	Description:	Entry point. Auto-run via CfgFunctions postInit on EVERY machine.
					- Loads the central config on this machine.
					- Clients: attaches the FPV / terminal scroll actions to the player.
					- Server: framework-inits any Eden-placed drone already flagged as managed
					  or autonomous (fallback for drones whose init field did not call droneInit).
	Author:			Drone framework

  # RETURNED VALUE #
	[Nothing]
*/

// Config must exist on every machine (clients read DRONE_* for action labels / forwarding).
call compile preprocessFileLineNumbers "Drones\cfg\droneConfig.sqf";

// --- Client side: FPV / terminal actions on the player ------------------------
if (hasInterface) then {
	[] spawn {
		waitUntil { !isNull player };
		[player] call MyDrones_fnc_droneAddActions;
	};
};

// --- Server side: pick up pre-placed Eden drones ------------------------------
if (isServer) then {
	{
		private _managed = _x getVariable ["MyDrones_managed", false];
		private _auto = _x getVariable ["MyDrones_autonomous", false];
		if (_managed || _auto) then {
			[_x] call MyDrones_fnc_droneInit;
			if (_auto) then { [_x] call MyDrones_fnc_droneAutoHunt; };
		};
	} forEach (vehicles select { _x isKindOf "UAV" });
};
