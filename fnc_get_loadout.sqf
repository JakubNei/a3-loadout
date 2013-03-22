/*

  AUTHOR: aeroson
  NAME: fnc_get_loadout.sqf
  VERSION: 2
  
  
  PARAMETER(S):
  0 : target unit
  
  RETURNS:
  Array : array of strings/arrays containing target unit's loadout, to be used by fnc_set_loadout.sqf
  
  
  addAction support:
  Saves player's loadout into global var loadout

*/


_t = 0;

// addAction support
if(count _this == 1) then {
  _t = _this select 0;
} else {
  _t = player;
};

_d=[
assignedItems _t,

primaryWeapon _t,
primaryWeaponItems _t,

handgunWeapon _t,
handgunItems _t,

secondaryWeapon _t,
secondaryWeaponItems _t, 

uniform _t,
uniformItems _t,

vest _t,
vestItems _t,

backpack _t, 
backpackItems _t,

headgear _t,
goggles _t

];

// addAction support
if(count _this == 1) then {
  _d;
} else {  
  loadout = _d;
  profileNamespace setVariable ["loadout",loadout];
  saveProfileNamespace;
  playSound3D ["A3\Sounds_F\sfx\ZoomOut.wav", _t];
};   