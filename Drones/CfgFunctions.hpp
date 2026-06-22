/*
	Drones\CfgFunctions.hpp
	Registers the FPV / suicide-drone framework with the Functions Library.
	Included from description.ext. Functions become callable as MyDrones_fnc_<name>.

	Files resolve to Drones\functions\fn_<class>.sqf (CfgFunctions default naming).
*/
class CfgFunctions
{
	class MyDrones
	{
		class Drones
		{
			file = "Drones\functions";

			// Auto-runs on every machine after mission init: loads config + wires actions.
			class droneBootstrap { postInit = 1; };

			class droneInit {};			// per-drone setup (EHs, variables) — server-authoritative
			class droneKamikaze {};		// create warhead + destroy drone
			class droneDropBomb {};		// release ordnance, drone survives
			class droneAutoHunt {};		// autonomous search / dive / detonate loop
			class droneSpawn {};		// dynamic spawn + AI crew / terminal hookup
			class droneAddActions {};	// FPV scroll actions on the player
			class droneSelectAmmo {};	// cycle the warhead via the UAV terminal
		};
	};
};
