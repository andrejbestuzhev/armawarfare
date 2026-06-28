// =====================================================================
// PRICES :: UPGRADES   (ordered arrays, one [lvl1,lvl2,...] per upgrade)
// COSTS = money per level.  TIMES = research seconds per level.
// Order/length must match the upgrade list in Upgrades_<side>.sqf.
// Times keep the *CTI_UPGRADE_RATIO multiplier (defined in Init_CommonConstants).
// =====================================================================

//--- Upgrades/Upgrades_West.sqf: COSTS (22) ---
CTI_PRICES_UPGRADES_WEST = [
	[1000,2000,3000],	// [0] STR_Up_Barracks
	[5000],	// [1] STR_Up_Light_Factory
	[10000,50000],	// [2] STR_Up_Heavy_Factory
	[25000],	// [3] STR_Up_Aircraft_Factory
	[1500,2500,4000,6000,8000,12000],	// [4] STR_Up_AAF_technologies
	[10000],	// [5] STR_Up_Aircraft_FFAR
	[50000],	// [6] STR_Up_Aircraft_AT
	[50000],	// [7] STR_Up_Aircraft_AA
	[8000],	// [8] STR_Up_Air_Countermeasures
	[2000, 4000, 7500],	// [9] STR_Up_Gear
	[9000],	// [10] STR_Up_Tactical_Hud
	[5000, 20000, 40000],	// [11] STR_Up_Towns_Occupation
	[100000],	// [12] STR_Up_Satellite
	[4000],	// [13] STR_Up_Halo_Jump
	[6000],	// [14] STR_Up_Air_Radar
	[6000],	// [15] STR_Up_Artillery_Radar
	[2000,6000,12000],	// [16] STR_Up_Range
	[2000,6000,12000],	// [17] STR_Up_Intrusion
	[30000],	// [18] STR_Up_Data
	[6000,12000],	// [19] STR_Up_Trophy
	[6000,12000],	// [20] STR_Up_Max_Ammos
	[1000,2000,4000,8000,16000]	// [21] STR_Up_Respawn_Truck
];

//--- Upgrades/Upgrades_West.sqf: TIMES (22) ---
CTI_PRICES_UPGRADE_TIMES_WEST = [
	[10*CTI_UPGRADE_RATIO,20*CTI_UPGRADE_RATIO,30*CTI_UPGRADE_RATIO],	// [0] STR_Up_Barracks
	[90*CTI_UPGRADE_RATIO],	// [1] STR_Up_Light_Factory
	[180*CTI_UPGRADE_RATIO,240*CTI_UPGRADE_RATIO],	// [2] STR_Up_Heavy_Factory
	[90*CTI_UPGRADE_RATIO],	// [3] STR_Up_Aircraft_Factory
	[20*CTI_UPGRADE_RATIO,20*CTI_UPGRADE_RATIO,50*CTI_UPGRADE_RATIO,60*CTI_UPGRADE_RATIO,70*CTI_UPGRADE_RATIO,80*CTI_UPGRADE_RATIO],	// [4] STR_Up_AAF_technologies
	[90*CTI_UPGRADE_RATIO],	// [5] STR_Up_Aircraft_FFAR
	[90*CTI_UPGRADE_RATIO],	// [6] STR_Up_Aircraft_AT
	[90*CTI_UPGRADE_RATIO],	// [7] STR_Up_Aircraft_AA
	[60*CTI_UPGRADE_RATIO],	// [8] STR_Up_Air_Countermeasures
	[20*CTI_UPGRADE_RATIO, 40*CTI_UPGRADE_RATIO, 60*CTI_UPGRADE_RATIO],	// [9] STR_Up_Gear
	[120*CTI_UPGRADE_RATIO],	// [10] STR_Up_Tactical_Hud
	[60*CTI_UPGRADE_RATIO, 70*CTI_UPGRADE_RATIO, 80*CTI_UPGRADE_RATIO],	// [11] STR_Up_Towns_Occupation
	[120*CTI_UPGRADE_RATIO],	// [12] STR_Up_Satellite
	[20*CTI_UPGRADE_RATIO],	// [13] STR_Up_Halo_Jump
	[30*CTI_UPGRADE_RATIO],	// [14] STR_Up_Air_Radar
	[30*CTI_UPGRADE_RATIO],	// [15] STR_Up_Artillery_Radar
	[10*CTI_UPGRADE_RATIO,30*CTI_UPGRADE_RATIO,60*CTI_UPGRADE_RATIO],	// [16] STR_Up_Range
	[10*CTI_UPGRADE_RATIO,30*CTI_UPGRADE_RATIO,60*CTI_UPGRADE_RATIO],	// [17] STR_Up_Intrusion
	[60*CTI_UPGRADE_RATIO],	// [18] STR_Up_Data
	[20*CTI_UPGRADE_RATIO,40*CTI_UPGRADE_RATIO],	// [19] STR_Up_Trophy
	[20*CTI_UPGRADE_RATIO,40*CTI_UPGRADE_RATIO],	// [20] STR_Up_Max_Ammos
	[10*CTI_UPGRADE_RATIO,20*CTI_UPGRADE_RATIO,40*CTI_UPGRADE_RATIO,80*CTI_UPGRADE_RATIO,160*CTI_UPGRADE_RATIO]	// [21] STR_Up_Respawn_Truck
];

//--- Upgrades/Upgrades_East.sqf: COSTS (22) ---
CTI_PRICES_UPGRADES_EAST = [
	[1000,2000,3000],	// [0] STR_Up_Barracks
	[5000],	// [1] STR_Up_Light_Factory
	[10000,50000],	// [2] STR_Up_Heavy_Factory
	[25000],	// [3] STR_Up_Aircraft_Factory
	[1500,2500,4000,6000,8000,12000],	// [4] STR_Up_AAF_technologies
	[10000],	// [5] STR_Up_Aircraft_FFAR
	[50000],	// [6] STR_Up_Aircraft_AT
	[50000],	// [7] STR_Up_Aircraft_AA
	[8000],	// [8] STR_Up_Air_Countermeasures
	[2000, 4000, 7500],	// [9] STR_Up_Gear
	[9000],	// [10] STR_Up_Tactical_Hud
	[5000, 20000, 40000],	// [11] STR_Up_Towns_Occupation
	[100000],	// [12] STR_Up_Satellite
	[4000],	// [13] STR_Up_Halo_Jump
	[6000],	// [14] STR_Up_Air_Radar
	[6000],	// [15] STR_Up_Artillery_Radar
	[2000,6000,12000],	// [16] STR_Up_Range
	[2000,6000,12000],	// [17] STR_Up_Intrusion
	[30000],	// [18] STR_Up_Data
	[6000,12000],	// [19] STR_Up_Trophy
	[6000,12000],	// [20] STR_Up_Max_Ammos
	[1000,2000,4000,8000,16000]	// [21] STR_Up_Respawn_Truck
];

//--- Upgrades/Upgrades_East.sqf: TIMES (22) ---
CTI_PRICES_UPGRADE_TIMES_EAST = [
	[10*CTI_UPGRADE_RATIO,20*CTI_UPGRADE_RATIO,30*CTI_UPGRADE_RATIO],	// [0] STR_Up_Barracks
	[90*CTI_UPGRADE_RATIO],	// [1] STR_Up_Light_Factory
	[180*CTI_UPGRADE_RATIO,240*CTI_UPGRADE_RATIO],	// [2] STR_Up_Heavy_Factory
	[90*CTI_UPGRADE_RATIO],	// [3] STR_Up_Aircraft_Factory
	[20*CTI_UPGRADE_RATIO,20*CTI_UPGRADE_RATIO,50*CTI_UPGRADE_RATIO,60*CTI_UPGRADE_RATIO,70*CTI_UPGRADE_RATIO,80*CTI_UPGRADE_RATIO],	// [4] STR_Up_AAF_technologies
	[90*CTI_UPGRADE_RATIO],	// [5] STR_Up_Aircraft_FFAR
	[90*CTI_UPGRADE_RATIO],	// [6] STR_Up_Aircraft_AT
	[90*CTI_UPGRADE_RATIO],	// [7] STR_Up_Aircraft_AA
	[60*CTI_UPGRADE_RATIO],	// [8] STR_Up_Air_Countermeasures
	[20*CTI_UPGRADE_RATIO, 40*CTI_UPGRADE_RATIO, 60*CTI_UPGRADE_RATIO],	// [9] STR_Up_Gear
	[120*CTI_UPGRADE_RATIO],	// [10] STR_Up_Tactical_Hud
	[60*CTI_UPGRADE_RATIO, 70*CTI_UPGRADE_RATIO, 80*CTI_UPGRADE_RATIO],	// [11] STR_Up_Towns_Occupation
	[120*CTI_UPGRADE_RATIO],	// [12] STR_Up_Satellite
	[20*CTI_UPGRADE_RATIO],	// [13] STR_Up_Halo_Jump
	[30*CTI_UPGRADE_RATIO],	// [14] STR_Up_Air_Radar
	[30*CTI_UPGRADE_RATIO],	// [15] STR_Up_Artillery_Radar
	[10*CTI_UPGRADE_RATIO,30*CTI_UPGRADE_RATIO,60*CTI_UPGRADE_RATIO],	// [16] STR_Up_Range
	[10*CTI_UPGRADE_RATIO,30*CTI_UPGRADE_RATIO,60*CTI_UPGRADE_RATIO],	// [17] STR_Up_Intrusion
	[60*CTI_UPGRADE_RATIO],	// [18] STR_Up_Data
	[20*CTI_UPGRADE_RATIO,40*CTI_UPGRADE_RATIO],	// [19] STR_Up_Trophy
	[20*CTI_UPGRADE_RATIO,40*CTI_UPGRADE_RATIO],	// [20] STR_Up_Max_Ammos
	[10*CTI_UPGRADE_RATIO,20*CTI_UPGRADE_RATIO,40*CTI_UPGRADE_RATIO,80*CTI_UPGRADE_RATIO,160*CTI_UPGRADE_RATIO]	// [21] STR_Up_Respawn_Truck
];
