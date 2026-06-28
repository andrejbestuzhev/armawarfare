/*
	Drones\gui.hpp
	"Set bomb" popup for the FPV / suicide-drone framework.
	Included from description.ext AFTER the Rsc\*.hpp files, so the engine base controls
	RscText / RscButton / IGUIBack (defined in Rsc\Resources.hpp) are available to inherit.

	Opened with: createDialog "MyDrones_SetBombDialog"
	The target drone is read from missionNamespace "MyDrones_setBombTarget".
*/
class MyDrones_SetBombDialog
{
	idd = 9100;
	movingEnable = 0;
	enableSimulation = 1;

	class controlsBackground
	{
		class Bg: IGUIBack
		{
			idc = -1;
			x = "0.5 - 0.16"; y = "0.5 - 0.17"; w = 0.32; h = 0.40;
		};
	};

	class controls
	{
		class Title: RscText
		{
			idc = 9101;
			text = "Set drone bomb";
			style = 2;	// ST_CENTER
			colorBackground[] = {0.18, 0.18, 0.18, 0.9};
			x = "0.5 - 0.16"; y = "0.5 - 0.17"; w = 0.32; h = 0.045;
		};
		class BtnNone: RscButton
		{
			idc = -1;
			text = "None (remove)";
			x = "0.5 - 0.14"; y = "0.5 - 0.10"; w = 0.28; h = 0.05;
			action = "[(missionNamespace getVariable ['MyDrones_setBombTarget', objNull]), 'none'] call MyDrones_fnc_droneSetBomb; closeDialog 0;";
		};
		class BtnGrenade: RscButton
		{
			idc = -1;
			text = "Frag grenade";
			x = "0.5 - 0.14"; y = "0.5 - 0.035"; w = 0.28; h = 0.05;
			action = "[(missionNamespace getVariable ['MyDrones_setBombTarget', objNull]), 'grenade'] call MyDrones_fnc_droneSetBomb; closeDialog 0;";
		};
		class BtnSatchel: RscButton
		{
			idc = -1;
			text = "Satchel charge";
			x = "0.5 - 0.14"; y = "0.5 + 0.03"; w = 0.28; h = 0.05;
			action = "[(missionNamespace getVariable ['MyDrones_setBombTarget', objNull]), 'satchel'] call MyDrones_fnc_droneSetBomb; closeDialog 0;";
		};
		class BtnRpg: RscButton
		{
			idc = -1;
			text = "RPG rocket";
			x = "0.5 - 0.14"; y = "0.5 + 0.095"; w = 0.28; h = 0.05;
			action = "[(missionNamespace getVariable ['MyDrones_setBombTarget', objNull]), 'rpg'] call MyDrones_fnc_droneSetBomb; closeDialog 0;";
		};
		class BtnCancel: RscButton
		{
			idc = -1;
			text = "Cancel";
			colorBackground[] = {0.5, 0.18, 0.18, 0.8};
			x = "0.5 - 0.14"; y = "0.5 + 0.16"; w = 0.28; h = 0.045;
			action = "closeDialog 0;";
		};
	};
};
