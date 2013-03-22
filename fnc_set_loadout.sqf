/*

  AUTHOR: aeroson
  NAME: fnc_set_loadout.sqf
  VERSION: 2.7
  
  
  PARAMETER(S):
  0 : target unit
  1 : array of strings/arrays containing desired target unit's loadout, obtained from fnc_get_loadout.sqf
  
  
  addAction support:
  Sets player's loadout from global var loadout
  
*/


_t = 0;
_d = 0;

// addAction support
if(count _this == 2) then {
  _t = _this select 0;
  _d = _this select 1;
} else {
  _t = player;
  _d = loadout;
  playSound3D ["A3\Sounds_F\sfx\ZoomIn.wav", _t];  
};


if(count _d != 15) exitWith {
  if(_t == player) then {
    hint "You were trying to set/load corrupted loadout";
  };
};


_s = false; // did we already do selectWeapon ?


_add = {
  private ["_c","_i"];
  _c = _this select 0;
  _i = _this select 1;
  if(isClass(configFile>>"CfgMagazines">>_i)) then {
    _c addMagazine _i;
  } else {
    if(isClass(configFile>>"CfgWeapons">>_i>>"WeaponSlotsInfo")&&getNumber(configFile>>"CfgWeapons">>_i>>"showempty")==1) then {
      _c addWeapon _i;
    } else {
      _c addItem _i;
    };
  };
};  


// we need to add items somewhere before we can assign them
removeBackpack _t;
_t addBackpack "B_AssaultPack_blk"; 
removeAllAssignedItems _t;
{ 
  [_t,_x] call _add;
  _t assignItem _x;
} foreach (_d select 0);


_t removeWeapon (primaryWeapon _t);
_w = _d select 1;             
if(_w != "") then {             
  _m = getArray(configFile>>"CfgWeapons">>_w>>"magazines") select 0;                                               
  _t addMagazine _m; // add primary weapon mag    
  waitUntil{_m in magazines _t};
                                                                                                             
  _mz = getArray(configFile>>"CfgWeapons">>_w>>"muzzles");
  { 
    if (_x != "this") then {
      _m = getArray(configFile>>"CfgWeapons">>_w>>_x>>"magazines") select 0;
      _t addMagazine _m;
      waitUntil{_m in magazines _t}; 
    };
  } forEach _mz; // add one mag for each muzzle
                
  _t addWeapon _w;                                                                                    
  { if(_x!="") then { _t removeItemFromPrimaryWeapon _x }; } forEach (primaryWeaponItems _t);                                 
  { if(_x!="") then { _t addPrimaryWeaponItem _x; }; } foreach (_d select 2);                             
                                              
  if (_mz select 0 != "this") then {                                                                        
    _w = _mz select 0;                                                                                      
  };                                                                                                        
  _t selectWeapon _w;                                                                                       
  _s = true;                                                                                                   
};

_t removeWeapon (handgunWeapon _t);
_w =_d select 3;
if(_w != "") then {
  _m = (getArray(configFile>>"CfgWeapons">>_w>>"magazines") select 0);
  _t addMagazine _m;
  waitUntil{_m in magazines _t};
  _t addWeapon _w;
  { if(_x!="") then { _t addHandgunItem _x; }; } foreach (_d select 4);
  if(!_s) then {
    _t selectWeapon _w;
    _s = true;  
  };
};
                                       
_t removeWeapon (secondaryWeapon _t);
_w = _d select 5;
if(_w != "") then {
  _m = (getArray(configFile>>"CfgWeapons">>_w>>"magazines") select 0);
  _t addMagazine _m;
  waitUntil{_m in magazines _t};
  _t addWeapon _w;
  { if(_x!="") then { _t addSecondaryWeaponItem _x; }; } foreach (_d select 6);
  if(!_s) then {
    _t selectWeapon _w;
    _s = true;  
  };
};

removeUniform _t;
_p = 0;
if(_d select 7 != "") then {
  _t addUniform (_d select 7);
  { [_t,_x] call _add; } foreach (_d select 8);
  // fill uniform with placeholders
  while { loadUniform _t < 1 } do {
    _t addItem "ItemWatch";
    _p = _p + 1;
  };
  
}; 

removeVest _t;
if(_d select 9 != "") then {
  _t addVest (_d select 9);
  { [_t,_x] call _add; } foreach (_d select 10);
};       

_add = {
  private ["_c","_i"];
  _c = _this select 0;
  _i = _this select 1;
  if(isClass(configFile>>"CfgMagazines">>_i)) then {
    _c addMagazineCargo [_i,1];
  } else {
    if(getNumber(configFile>>"CfgVehicles">>_i>>"isbackpack")==1) then {
      _c addBackpackCargo [_i,1];
    } else {
      if(isClass(configFile>>"CfgWeapons">>_i>>"WeaponSlotsInfo")&&getNumber(configFile>>"CfgWeapons">>_i>>"showempty")==1) then {
        _c addWeaponCargo [_i,1];  
      } else {
        _c addItemCargo [_i,1];        
      };
    };
  };
};         

removeBackpack _t;
if(_d select 11!="") then {
  _t addBackpack (_d select 11);                                                                    
  _c = unitBackpack _t; 
  clearWeaponCargo _c;
  clearMagazineCargo _c;
  clearItemCargo _c;
  clearBackpackCargo _c;   
  { [_c,_x] call _add; } foreach (_d select 12);
};

// remove placeholders
for "_i" from 1 to _p do {
  _t removeItem "ItemWatch"; 
};

removeHeadgear _t;
if(_d select 13!="") then {
  _t addHeadgear (_d select 13);
};

removeGoggles _t;
if(_d select 14!="") then {
  _t addGoggles (_d select 14);
};

_t setPos (getPos _t);
