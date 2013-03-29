/*

  AUTHOR: aeroson
  NAME: fnc_get_loadout.sqf
  VERSION: 2.1
  
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

private ["_target","_data"];


// addAction support
if(count _this == 1) then {
  _target = _this select 0;
} else {
  _target = player;
};

_data=[
assignedItems _target,

primaryWeapon _target,
primaryWeaponItems _target,

handgunWeapon _target,
handgunItems _target,

secondaryWeapon _target,
secondaryWeaponItems _target, 

uniform _target,
uniformItems _target,

vest _target,
vestItems _target,

backpack _target, 
backpackItems _target,

headgear _target,
goggles _target

];

// addAction support
if(count _this == 1) then {
  _data;
} else {  
  loadout = _data;
  profileNamespace setVariable ["loadout",loadout];
  saveProfileNamespace;
  playSound3D ["A3\Sounds_F\sfx\ZoomOut.wav", _target];
};   
