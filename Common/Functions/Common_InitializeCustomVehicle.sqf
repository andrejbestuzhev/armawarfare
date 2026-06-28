/*
  # HEADER #
	Script: 		Common\Functions\Common_InitializeCustomVehicle.sqf
	Alias:			CTI_CO_FNC_InitializeCustomVehicle
	Description:	Perform a custom vehicle/unit initialization
	Author: 		Benny
	Creation Date:	18-09-2013
	Revision Date:	11-10-2013

  # PARAMETERS #
    0	[Object]: The unit/vehicle
    1	[Side]: The side of the unit/vehicle
    2	[String]: The script to trigger

  # RETURNED VALUE #
	None

  # SYNTAX #
	[ENTITY, SIDE, SCRIPT] call CTI_CO_FNC_InitializeCustomVehicle

  # DEPENDENCIES #
	Depends on the initialization of the units

  # EXAMPLE #
    [vehicle player, CTI_P_SideJoined, "service-repairtruck"] call CTI_CO_FNC_InitializeCustomVehicle
	  -> This will initialize the vehicle of the player with the "service-repairtruck" script
*/

private ["_vehicle", "_script", "_side"];

_vehicle = _this select 0;
_side = _this select 1;
_script = _this select 2;

if (CTI_Log_Level >= CTI_Log_Debug) then {
	["DEBUG", "FILE: Common\Functions\Common_InitializeCustomVehicle.sqf", format["Attempting to perform custom initialization of vehicle [%1] on side [%2] with script [%3]", typeOf _vehicle, _side, _script]] call CTI_CO_FNC_Log;
};

switch (_script) do {
	case "salvager": {if (CTI_IsServer) then {(_vehicle) execFSM "Server\FSM\update_salvager.fsm"} else {["SERVER", "Request_HandleAction", ["salvager", _vehicle]] call CTI_CO_FNC_NetSend}};
	case "salvager-independent": { _sideLogic = (_side) call CTI_CO_FNC_GetSideLogic; _sideLogic setVariable ["cti_salvagers", (_sideLogic getVariable "cti_salvagers") + [_vehicle], true]; [_side, _vehicle] execFSM "Server\FSM\update_salvager_independent.fsm"};
	case "service-repairtruck": {_vehicle setVariable ["cti_spec", [CTI_SPECIAL_REPAIRTRUCK], true]; if (CTI_IsServer) then {[_vehicle, _side] execFSM "Server\FSM\update_repairtruck.fsm"} else {["SERVER", "Request_HandleAction", ["repair", [_vehicle, _side]]] call CTI_CO_FNC_NetSend}};
	case "service-ammotruck": {_vehicle setVariable ["cti_spec", [CTI_SPECIAL_AMMOTRUCK], true]};
	case "service-fueltruck": {_vehicle setVariable ["cti_spec", [CTI_SPECIAL_FUELTRUCK], true]};
	case "service-gear": {_vehicle setVariable ["cti_spec", [CTI_SPECIAL_GEAR], true]};

	case "service-medic": {if ((missionNamespace getVariable "CTI_RESPAWN_MOBILE") > 0) then {_vehicle setVariable ["cti_spec", [CTI_SPECIAL_MEDICALVEHICLE], true]}};

	case "service-radio": { //--- Mobile radio retransmitter / jammer (Hunter/Ifrit Radio)
		_vehicle setVariable ["cti_spec", [CTI_SPECIAL_RADIO], true];
		_vehicle setVariable ["cti_radio_mode", 0, true]; //--- 0 = off, 1 = retranslation, 2 = jamming

		//--- Mode-toggle context actions on every machine (JIP-safe). execVM compiles per-client, no global wiring needed.
		private _jipId = format ["cti_radio_act_%1", _vehicle call BIS_fnc_netId];
		_vehicle setVariable ["cti_radio_jipid", _jipId, true];
		[[_vehicle], "Addons\Strat_mode\Radio\Radio_AddActions.sqf"] remoteExec ["execVM", 0, _jipId];

		if (CTI_IsServer) then {
			//--- Attach the satellite antenna (with a safe fallback if the Sand variant is absent)
			private _antClass = "Land_SatelliteAntenna_01_Sand_F";
			if !(isClass (configFile >> "CfgVehicles" >> _antClass)) then {_antClass = "Land_SatelliteAntenna_01_F"};
			private _antenna = _antClass createVehicle [0, 0, 0];
			_antenna attachTo [_vehicle, [0, -1.5, 1.2]];
			_antenna enableSimulationGlobal false;   //--- purely visual; don't let the structure's physics fight the car
			_antenna setVariable ["cti_radio_antenna", true, true];
			_vehicle setVariable ["cti_radio_antenna", _antenna, true];

			[_vehicle, _side] execVM "Addons\Strat_mode\Radio\Radio_ServerVehicle.sqf";
		};
	};
};