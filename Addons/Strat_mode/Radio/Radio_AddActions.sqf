/*
	Radio_AddActions.sqf
	Adds the mobile-radio mode-toggle scroll-wheel actions to a Radio Hunter/Ifrit.
	Runs on every machine via remoteExec ["execVM", 0, <jip id>] from
	Common\Functions\Common_InitializeCustomVehicle.sqf (case "service-radio").

	Modes (stored in "cti_radio_mode", broadcast): 0 = off, 1 = retranslation, 2 = jamming.
	Both "on" options stay visible at all times (gated only by alive + near-stationary) so
	you can freely switch between modes — they do NOT hide the mode that is currently active
	(that made the menu look like it could only be used once). The active mode is shown with a
	tick in its label instead. Turning a mode ON requires the vehicle to be near-stationary
	(it resets to OFF on the move anyway, see Radio_ServerVehicle.sqf).
*/

params [["_veh", objNull, [objNull]]];

if (isNull _veh) exitWith {};
if (!hasInterface) exitWith {};                                  //--- dedicated server has no scroll menu
if (_veh getVariable ["cti_radio_actions_added", false]) exitWith {};
_veh setVariable ["cti_radio_actions_added", true];

_veh addAction [
	"<t color='#7DD3FC'>Radio: retranslation</t>",
	{(_this select 0) setVariable ["cti_radio_mode", 1, true]; hintSilent "Radio: retranslation ON"},
	[],
	1.5, false, true, "",
	"alive _target && (_target getVariable ['cti_radio_mode',0]) != 1 && (abs speed _target) < 3"
];

_veh addAction [
	"<t color='#7DD3FC'>Radio: retranslation</t> <t color='#22C55E'>(active)</t>",
	{(_this select 0) setVariable ["cti_radio_mode", 0, true]; hintSilent "Radio: off"},
	[],
	1.5, false, true, "",
	"alive _target && (_target getVariable ['cti_radio_mode',0]) == 1"
];

_veh addAction [
	"<t color='#FCA5A5'>Radio: jamming (1.5 km, friend &amp; foe)</t>",
	{(_this select 0) setVariable ["cti_radio_mode", 2, true]; hintSilent "Radio: jamming ON (1.5 km, friend & foe)"},
	[],
	1.5, false, true, "",
	"alive _target && (_target getVariable ['cti_radio_mode',0]) != 2 && (abs speed _target) < 3"
];

_veh addAction [
	"<t color='#FCA5A5'>Radio: jamming</t> <t color='#22C55E'>(active)</t>",
	{(_this select 0) setVariable ["cti_radio_mode", 0, true]; hintSilent "Radio: off"},
	[],
	1.5, false, true, "",
	"alive _target && (_target getVariable ['cti_radio_mode',0]) == 2"
];
