/*

  AUTHOR: aeroson
  NAME: fnc_set_loadout.sqf
  VERSION: 3.1
  
  DOWNLOAD & PARTICIPATE:
  https://github.com/aeroson/get-set-loadout
  http://forums.bistudio.com/showthread.php?148577-GET-SET-Loadout-(saves-and-loads-pretty-much-everything)
  
  PARAMETER(S):
  0 : target unit
  1 : array of strings/arrays containing desired target unit's loadout, obtained from fnc_get_loadout.sqf
  
  
  addAction support:
  Sets player's loadout from global var loadout
  
*/

private ["_target","_data","_selectedWeapon","_weapon","_magazine","_muzzles","_magazine","_outfit","_placeholderCount"];


// addAction support
if(count _this == 2) then {
	_target = _this select 0;
	_data = _this select 1;
} else {
	_target = player;
	_data = loadout;
	playSound3D ["A3\Sounds_F\sfx\ZoomIn.wav", _target];  
};

if(count _data != 15) exitWith {
	if(_target == player) then {
		hint "You were trying to set/load corrupted loadout";
	};
};

_placeholderCount = 0;
_selectedWeapon = false; // did we already do selectWeapon ?

_add = {
	private ["_cargo","_item"];
	_cargo = _this select 0;
	_item = _this select 1;
	if(isClass(configFile>>"CfgMagazines">>_item)) then {
		_cargo addMagazine _item;
	} else {
		if(isClass(configFile>>"CfgWeapons">>_item>>"WeaponSlotsInfo") AND getNumber(configFile>>"CfgWeapons">>_item>>"showempty")==1) then {
			_cargo addWeapon _item;  
		} else {
			_cargo addItem _item;        
		};
	};
};

// we need to add items somewhere before we can assign them
removeBackpack _target;
_target addBackpack "B_AssaultPack_blk"; 
removeAllAssignedItems _target;
{ 
	[_target,_x] call _add;
	_target assignItem _x;
} foreach (_data select 0);

_target removeWeapon (primaryWeapon _target);
_weapon = _data select 1;             
if(_weapon != "") then {             
	_magazine = getArray(configFile>> "CfgWeapons">>_weapon>>"magazines") select 0;                                               
	_target addMagazine _magazine; // add primary weapon mag    
	waitUntil { _magazine in (magazines _target) };
	 
	_muzzles = getArray(configFile>>"CfgWeapons">>_weapon>> "muzzles");   
	
	// add one mag for each muzzle
	{ 
		if (_x != "this") then {
			_magazine = getArray(configFile>>"CfgWeapons">>_weapon>>_x>>"magazines") select 0;
			_target addMagazine _magazine;
			waitUntil { _magazine in (magazines _target) }; 
		};
	} forEach _muzzles; 
				
	_target addWeapon _weapon;                                                                                    
	{ if(_x!="") then { _target removeItemFromPrimaryWeapon _x }; } forEach (primaryWeaponItems _target);                                 
	{ if(_x!="") then { _target addPrimaryWeaponItem _x; }; } foreach (_data select 2);                             
											  
	if (_muzzles select 0 != "this") then {                                                                        
		_weapon = _muzzles select 0;                                                                                      
	};
	
	_target selectWeapon _weapon;                                                                                       
	_selectedWeapon = true;                                                                                                   
};

_target removeWeapon (handgunWeapon _target);
_weapon =_data select 3;
if(_weapon != "") then {
	_magazine = getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0;
	_target addMagazine _magazine;
	waitUntil { _magazine in (magazines _target) };
	
	_target addWeapon _weapon;
	{ if(_x!="") then { _target addHandgunItem _x; }; } foreach (_data select 4);
	
	if(!_selectedWeapon) then {
		_target selectWeapon _weapon;
		_selectedWeapon = true;  
	};
};
                                       
_target removeWeapon (secondaryWeapon _target);
_weapon = _data select 5;
if(_weapon != "") then {
	_magazine = getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0;
	_target addMagazine _magazine;
	waitUntil { _magazine in (magazines _target) };
	
	_target addWeapon _weapon;
	{ if(_x!="") then { _target addSecondaryWeaponItem _x; }; } foreach (_data select 6);
	
	if(!_selectedWeapon) then {
		_target selectWeapon _weapon;
		_selectedWeapon = true;  
	};
};

removeUniform _target;
_outfit = _data select 7;  
if(_outfit != "") then {
	_target addUniform _outfit;
	waitUntil { uniform _target == _outfit };
	{ [_target,_x] call _add; } foreach (_data select 8);
	
	while { loadUniform _target < 1 } do {
		_target addItem "ItemWatch";
		_placeholderCount = _placeholderCount + 1;
	};
};

removeVest _target;
_outfit = _data select 9; 
if(_outfit != "") then {
	_target addVest _outfit;
	waitUntil { vest _target == _outfit };
	{ [_target,_x] call _add; } foreach (_data select 10);

	while { loadVest _target < 1 } do {
		_target addItem "ItemWatch";
		_placeholderCount = _placeholderCount + 1;
	};
};       

removeBackpack _target;
_outfit = _data select 11; 
if(_outfit != "") then {
	_target addBackpack _outfit;
	waitUntil { backpack _target == _outfit };                                                                    
	clearAllItemsFromBackpack _target;
	{ [_target,_x] call _add; } foreach (_data select 12);
};

// remove placeholders
for "_i" from 1 to _placeholderCount do {
	_target removeItem "ItemWatch"; 
};

_target setPos (getPos _target);
