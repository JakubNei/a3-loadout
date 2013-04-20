/*

	AUTHOR: aeroson
	NAME: fnc_get_loadout.sqf
	VERSION: 2.6
	
	DOWNLOAD & PARTICIPATE:
	https://github.com/aeroson/get-set-loadout
	http://forums.bistudio.com/showthread.php?148577-GET-SET-Loadout-(saves-and-loads-pretty-much-everything)
	
	PARAMETER(S):
	0 : target unit
	
	RETURNS:
	Array : array of strings/arrays containing target unit's loadout, to be used by fnc_set_loadout.sqf
	
	
	addAction support:
	Saves player's loadout into global var loadout

*/


private ["_target","_weapon","_magazine","_magazines","_muzzles","_currentWeapon","_currentMode","_loadedMagazines","_data"];

// addAction support
if(count _this < 3) then {
	_target = _this select 0;
} else {
	_target = player;
};                         

if ( vehicle player == player ) then {
	_currentWeapon = currentMuzzle _target;
	_currentMode = currentWeaponMode _target;
} else {
	_currentWeapon = "";
	_currentMode = "";
};
	
_loadedMagazines = [];

_magazines = [];
_weapon = primaryWeapon _target; 
if(_weapon != "") then {
	_target selectWeapon _weapon;
	_magazines = [toLower(currentMagazine _target)];
	_muzzles = getArray(configFile>>"CfgWeapons">>_weapon>>"muzzles"); 	
	{ // add one mag for each muzzle
		if (_x != "this") then {
			_target selectWeapon _x;
			_magazines set [count _magazines, toLower(currentMagazine _target)];
		};
	} forEach _muzzles;		
};
_loadedMagazines set [count _loadedMagazines, _magazines];

_magazine = "";
_weapon = handgunWeapon player;
if(_weapon != "") then {
	_target selectWeapon _weapon;
	_magazine = currentMagazine _target;
};
_loadedMagazines set [count _loadedMagazines, _magazine];
	
_magazine = "";
_weapon = secondaryWeapon _target;
if(_weapon != "") then {
	_target selectWeapon _weapon;
	_magazine = currentMagazine _target;
};
_loadedMagazines set [count _loadedMagazines, _magazine];


if ( _currentWeapon != "" && _currentMode != "" ) then {
	_muzzles = 0;
	while { (_currentWeapon != currentMuzzle _target || _currentMode != currentWeaponMode _target ) && _muzzles < 200 } do {
		_target action ["SWITCHWEAPON", _target, _target, _muzzles];
		_muzzles = _muzzles + 1;
	};
};

	
_data=[
	assignedItems _target, //0

	primaryWeapon _target, //1
	primaryWeaponItems _target, //2

	handgunWeapon _target, //3
	handgunItems _target, //4

	secondaryWeapon _target, //5
	secondaryWeaponItems _target, //6 

	uniform _target, //7
	uniformItems _target, //8

	vest _target, //9
	vestItems _target, //10

	backpack _target, //11 
	backpackItems _target, //12

	_loadedMagazines, //13 (optional)
	_currentWeapon, //14 (optional)
	_currentMode //15 (optional)
];

// addAction support
if(count _this < 3) then {
	_data;
} else {  
	loadout = _data;
	profileNamespace setVariable ["loadout",loadout];
	saveProfileNamespace;
	//playSound3D ["A3\Sounds_F\sfx\ZoomOut.wav", _target];
};   
