/*

	EDIT BY: aeroson (github.com/aeroson/a3-loadout)
	
	DESCRIPTION:
	this is edited function of VAS
	http://forums.bistudio.com/showthread.php?149077-Virtual-Ammobox-System-(VAS)
	
	REQUIRES:
	in client's init:
	getLoadout = compile preprocessFileLineNumbers 'get_loadout.sqf';
	setLoadout = compile preprocessFileLineNumbers 'set_loadout.sqf';
	
	USAGE:
	replace 'VAS\functions\fn_loadGear.sqf'
	with this script		
      
*/

waitUntil{!isNil{getLoadout} && !isNil{setLoadout}};

#include "macro.sqf"

private["_slot","_loadout"];
if(!isNil {VAS_loadout_ip}) exitWith {};
_slot = if(isNil {_this select 0}) then {lbCurSel VAS_load_list} else {_this select 0};
if(_slot == -1) exitWith {hint "You didn't select a slot to load!";};
if(vas_disableLoadSave) then
{
	_loadout = missionNamespace getVariable format["vas_gear_new_%1",_slot];
}
	else
{
	_loadout = profileNamespace getVariable format["vas_gear_new_%1",_slot];
};

if(isNil {_loadout}) exitWith {}; //Slot data doesn't exist

VAS_loadout_ip = true;

[player,
	[
		_loadout select 8, // assigned items
		
		_loadout select 1, // primary
		_loadout select 9, // primary items
		
		_loadout select 3, // handgun
		_loadout select 11, // handugn items 
		
		_loadout select 2, // secondary
		_loadout select 10, // secondary items
		
		_loadout select 5, // uniform
		_loadout select 12, // uniform items
		
		_loadout select 6, // vest
		_loadout select 13, // vest items
		
		_loadout select 7, // backpack
		_loadout select 14, // backpack items
		
		[_loadout select 4,[],[]] // loaded magazines
	]
] call setLoadout;

VAS_loadout_ip = nil;
