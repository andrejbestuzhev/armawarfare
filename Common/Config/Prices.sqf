// ============================================================
// CENTRAL PRICE BOOK -- loader + debug switch.
// Actual prices/times live in the split files under Common\Config\Prices\ :
//   Units.sqf      -- unit & vehicle prices + build times
//   Inventory.sqf  -- weapon / magazine / item prices
//   Upgrades.sqf   -- upgrade costs + research times
//   Buildings.sqf  -- structure prices + build times, defense prices
// Source config files read these maps and override their inline defaults;
// an entry absent here keeps that file's inline fallback value.
//   UNITS / GEAR / BUILDINGS : keyed by classname
//   UPGRADES                 : ordered array, one [lvl1,lvl2,...] per upgrade
// ============================================================

// ===== DEBUG MODE =====
// true  -> every price = 1, every time (research / build) = 1 second.
// false -> normal prices/times from the files below.  SET false FOR PRODUCTION.
CTI_PRICES_DEBUG = true;

// --- load the split price books ---
call compile preprocessFileLineNumbers "Common\Config\Prices\Units.sqf";
call compile preprocessFileLineNumbers "Common\Config\Prices\Inventory.sqf";
call compile preprocessFileLineNumbers "Common\Config\Prices\Upgrades.sqf";
call compile preprocessFileLineNumbers "Common\Config\Prices\Buildings.sqf";

// ===== DEBUG APPLY =====
// Force every value in every map/array above to 1. The source-file override
// blocks then propagate these 1s into prices/times automatically.
if (CTI_PRICES_DEBUG) then {
	// hashmaps (classname -> value): set every value to 1
	{
		private _map = missionNamespace getVariable _x;
		if (!isNil "_map") then { { _map set [_x, 1] } forEach (keys _map); };
	} forEach [
		"CTI_PRICES_UNITS_WEST", "CTI_PRICES_UNITS_EAST", "CTI_PRICES_UNITS_RESISTANCE",
		"CTI_PRICES_UNIT_TIMES_WEST", "CTI_PRICES_UNIT_TIMES_EAST", "CTI_PRICES_UNIT_TIMES_RESISTANCE",
		"CTI_PRICES_GEAR_WEST", "CTI_PRICES_GEAR_EAST",
		"CTI_PRICES_STRUCTURES_WEST", "CTI_PRICES_STRUCTURES_EAST",
		"CTI_PRICES_STRUCT_TIMES_WEST", "CTI_PRICES_STRUCT_TIMES_EAST",
		"CTI_PRICES_DEFENSES_WEST", "CTI_PRICES_DEFENSES_EAST"
	];
	// ordered arrays (array of [lvl,...]): set every level to 1
	{
		private _arr = missionNamespace getVariable _x;
		if (!isNil "_arr") then { { _arr set [_forEachIndex, _x apply {1}] } forEach _arr; };
	} forEach [
		"CTI_PRICES_UPGRADES_WEST", "CTI_PRICES_UPGRADES_EAST",
		"CTI_PRICES_UPGRADE_TIMES_WEST", "CTI_PRICES_UPGRADE_TIMES_EAST"
	];
};
