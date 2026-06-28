/*
	Radio_AddActions.sqf
	Adds the mobile-radio mode-toggle scroll-wheel actions to a Radio Hunter/Ifrit.
	Runs on every machine via remoteExec ["execVM", 0, <jip id>] from
	Common\Functions\Common_InitializeCustomVehicle.sqf (case "service-radio").

	Modes (stored in "cti_radio_mode", broadcast): 0 = off, 1 = retranslation, 2 = jamming.
	The three options are mutually exclusive: each one only shows while it is NOT the
	current mode, so picking one always sets a single mode. Turning a mode ON requires
	the vehicle to be near-stationary (it resets to OFF on the move anyway, see
	Radio_ServerVehicle.sqf).
*/

params [["_veh", objNull, [objNull]]];

if (isNull _veh) exitWith {};
if (!hasInterface) exitWith {};                                  //--- dedicated server has no scroll menu
if (_veh getVariable ["cti_radio_actions_added", false]) exitWith {};
_veh setVariable ["cti_radio_actions_added", true];

_veh addAction [
	"<t color='#7DD3FC'>Radio: Turn on retranslation</t>",
	{(_this select 0) setVariable ["cti_radio_mode", 1, true]; hintSilent "Radio: retranslation ON"},
	[],
	1.5, false, true, "",
	"alive _target && (_target getVariable ['cti_radio_mode',0]) != 1 && (abs speed _target) < 3"
];

_veh addAction [
	"<t color='#FCA5A5'>Radio: Turn on jamming</t>",
	{(_this select 0) setVariable ["cti_radio_mode", 2, true]; hintSilent "Radio: jamming ON (1.5 km, friend & foe)"},
	[],
	1.5, false, true, "",
	"alive _target && (_target getVariable ['cti_radio_mode',0]) != 2 && (abs speed _target) < 3"
];

_veh addAction [
	"<t color='#D1D5DB'>Radio: Turn off</t>",
	{(_this select 0) setVariable ["cti_radio_mode", 0, true]; hintSilent "Radio: off"},
	[],
	1.5, false, true, "",
	"alive _target && (_target getVariable ['cti_radio_mode',0]) != 0"
];
