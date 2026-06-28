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
			class droneAddDroneActions {};// scroll actions on the drone object itself (all machines)
			class droneSetBombMenu {};	// open the "Set bomb" popup
			class droneSetBomb {};		// arm/clear payload, charge BECTI funds
			class droneSetPayload {};	// server-auth: set payload (ammo + broadcast visible model)
			class droneAttachPayload {};// runs on every machine: (re)attach the visible model(s)
		};
	};
};
