/*
	Radio_ServerVehicle.sqf      [server only]
	Per-vehicle controller for a Radio Hunter/Ifrit. execVM'd from
	Common\Functions\Common_InitializeCustomVehicle.sqf (case "service-radio").

	Reads the broadcast mode set by the scroll actions (Radio_AddActions.sqf):
		0 = off            -> inert, plain vehicle
		1 = retranslation  -> becomes an AdvNet relay node wired straight to the nearest
		                      Command Center, else the MHQ; nearby units relay through it
		                      (gaining radar visibility + CC connection). Reach scales with
		                      the Network Range upgrade, exactly like AdvNet vehicle range.
		2 = jamming        -> kills comms (and UAVs) within CTI_RADIO_JAM_RANGE for EVERYONE,
		                      own side and enemy alike.

	Driving the vehicle resets the mode to OFF.

	AdvNet vars touched here (see Addons\Strat_mode\AdvNet\):
		CTI_Net      -> owner side id (>=0) makes it a side network node, -11 = none
		AN_Conn      -> the node we hang off (the CC/MHQ anchor)
		AN_iNet      -> resolved network id; == side id means "connected"
		AN_Parrents  -> ancestry / loop-guard
	Jamming flags affected units with AN_Jammed = <expire time>, honoured by the guards
	patched into AN_CheckConn.sqf / AN_Reconfigure.sqf.
*/

#define AN_RANGE_BASE 1000   // matches AN_Range_V in AdvNet

params [["_veh", objNull, [objNull]], ["_side", west, [west]]];
if (isNull _veh) exitWith {};
if (!CTI_IsServer) exitWith {};

private _sideID = (_side) call CTI_CO_FNC_GetSideID;
private _lastPos = getPosATL _veh;
private _prevMode = -1;

//--- Antenna + jammer-registry cleanup when the vehicle dies
_veh addEventHandler ["Killed", {
	params ["_v"];
	private _ant = _v getVariable ["cti_radio_antenna", objNull];
	if (!isNull _ant) then { deleteVehicle _ant };
	missionNamespace setVariable ["CTI_RADIO_JAMMERS", (missionNamespace getVariable ["CTI_RADIO_JAMMERS", []]) - [_v], true];
	private _jip = _v getVariable ["cti_radio_jipid", ""];
	if (_jip != "") then { remoteExec ["", _jip] };   //--- drop the queued JIP action message
}];

while {alive _veh && !CTI_GameOver} do {
	private _mode = _veh getVariable ["cti_radio_mode", 0];

	//--- Movement reset: any real motion drops the mode back to OFF
	if (_mode != 0 && {(abs speed _veh) > 4 || (_veh distance _lastPos) > 8}) then {
		_mode = 0;
		_veh setVariable ["cti_radio_mode", 0, true];
	};
	_lastPos = getPosATL _veh;

	//--- NETR-scaled reach (same formula AdvNet uses for vehicles)
	private _netr = if (_side in [east, west]) then { ((_side) call CTI_CO_FNC_GetSideUpgrades) select CTI_UPGRADE_NETR } else { 0 };
	private _range = AN_RANGE_BASE + 1000 * _netr;

	switch (_mode) do {

		case 1: { //--- RETRANSLATION
			private _ccs = [CTI_CONTROLCENTER, (_side) call CTI_CO_FNC_GetSideStructures] call CTI_CO_FNC_GetSideStructuresByType;
			private _anchor = [_veh, _ccs] call CTI_CO_FNC_GetClosestEntity;
			if (!isNull _anchor && {!alive _anchor || (_veh distance2D _anchor) > _range}) then { _anchor = objNull };

			if (isNull _anchor) then {
				private _hq = (_side) call CTI_CO_FNC_GetSideHQ;
				if (!isNull _hq && {alive _hq && (_veh distance2D _hq) <= _range}) then { _anchor = _hq };
			};

			if (!isNull _anchor) then {
				//--- Hooked straight to a base anchor -> we carry the side network; nearby units relay through us
				_veh setVariable ["CTI_Net", _sideID, true];
				_veh setVariable ["AN_Conn", _anchor, true];
				_veh setVariable ["AN_Parrents", [_veh], false];
				_veh setVariable ["AN_iNet", _sideID, true];
			} else {
				//--- No CC/MHQ within reach -> nothing to retransmit
				_veh setVariable ["AN_Conn", objNull, true];
				_veh setVariable ["AN_iNet", -1, true];
			};

			missionNamespace setVariable ["CTI_RADIO_JAMMERS", (missionNamespace getVariable ["CTI_RADIO_JAMMERS", []]) - [_veh], true];
		};

		case 2: { //--- JAMMING
			//--- not a relay while jamming
			_veh setVariable ["CTI_Net", -11, true];
			_veh setVariable ["AN_Conn", objNull, true];
			_veh setVariable ["AN_iNet", -1, true];

			//--- register as an active jammer (consumed by UAV_Range.sqf on every client)
			private _list = missionNamespace getVariable ["CTI_RADIO_JAMMERS", []];
			if !(_veh in _list) then { missionNamespace setVariable ["CTI_RADIO_JAMMERS", _list + [_veh], true] };

			//--- jam every man & vehicle in range, friend and foe; short TTL self-clears on the move / mode change
			private _expire = time + 5;
			{
				if (_x != _veh) then { _x setVariable ["AN_Jammed", _expire, true] };
			} forEach (_veh nearEntities [["Man", "Car", "Tank", "Air", "Ship"], CTI_RADIO_JAM_RANGE]);
		};

		default { //--- OFF
			_veh setVariable ["CTI_Net", -11, true];
			_veh setVariable ["AN_Conn", objNull, true];
			_veh setVariable ["AN_iNet", -1, true];
			missionNamespace setVariable ["CTI_RADIO_JAMMERS", (missionNamespace getVariable ["CTI_RADIO_JAMMERS", []]) - [_veh], true];
		};
	};

	if (_mode != _prevMode) then {
		_prevMode = _mode;
		if (!isNil "NET_LOG" && {NET_LOG}) then { diag_log format [":: RADIO :: %1 mode -> %2", _veh, _mode] };
	};

	sleep 2;
};

//--- cleanup on death / mission end
private _ant = _veh getVariable ["cti_radio_antenna", objNull];
if (!isNull _ant) then { deleteVehicle _ant };
missionNamespace setVariable ["CTI_RADIO_JAMMERS", (missionNamespace getVariable ["CTI_RADIO_JAMMERS", []]) - [_veh], true];
