/*

  AUTHOR: aeroson
  NAME: fnc_set_loadout.sqf
  VERSION: 3.4
  
  DOWNLOAD & PARTICIPATE:
  https://github.com/aeroson/get-set-loadout
  http://forums.bistudio.com/showthread.php?148577-GET-SET-Loadout-(saves-and-loads-pretty-much-everything)
  
  PARAMETER(S):
  0 : target unit
  1 : array of strings/arrays containing desired target unit's loadout, obtained from fnc_get_loadout.sqf
  
  
  addAction support:
  Sets player's loadout from global var loadout
  
*/


private ["_target","_data","_loadedMagazines","_selectedWeapon","_weapon","_magazine","_magazines","_muzzles","_outfit","_placeholderCount"];

// addAction support
if(count _this == 2) then {
	_target = _this select 0;
	_data = _this select 1;
} else {
	_target = player;
	_data = loadout;
	//playSound3D ["A3\Sounds_F\sfx\ZoomIn.wav", _target];  
};

if(count _data < 13) exitWith {
	if(_target == player) then {
		hint "You were trying to set/load corrupted loadout";
	};
};

_loadedMagazines = [];
if(count _data > 13) then {
	if(typeName(_data select 13)=="ARRAY") then {
		_loadedMagazines = _data select 13;
	};
};

_placeholderCount = 0;
_selectedWeapon = false; // did we already do selectWeapon ?

_add = {
	private ["_target","_item"];
	_target = _this select 0;
	_item = _this select 1;
	if(isClass(configFile>>"CfgMagazines">>_item)) then {
		_target addMagazine _item;
	} else {
		if(isClass(configFile>>"CfgWeapons">>_item>>"WeaponSlotsInfo") && getNumber(configFile>>"CfgWeapons">>_item>>"showempty")==1) then {
			_target addWeapon _item;  
		} else {
			_target addItem _item;        
		};
	};
};


removeUniform _target;
removeVest _target;
removeBackpack _target;

_outfit = "B_Kitbag_mcamo"; // we need to add items somewhere before we can assign them
_target addBackpack _outfit;
waitUntil { backpack _target == _outfit }; 
removeAllAssignedItems _target;
{ 
	[_target,_x] call _add;
	_target assignItem _x;
} foreach (_data select 0);


_target removeWeapon (primaryWeapon _target);
_weapon = _data select 1;             
if(_weapon != "") then {

	if(count _loadedMagazines > 0) then {
		_magazines = _loadedMagazines select 0; // get loaded magazines from saved loadout
	} else {          
		_magazines = [toLower(getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0)]; // generate default magazines
		_muzzles = getArray(configFile>>"CfgWeapons">>_weapon>>"muzzles"); 	
		{
			if (_x != "this") then {
				_magazines set [count _magazines, toLower(getArray(configFile>>"CfgWeapons">>_weapon>>_x>>"magazines") select 0)];
			};
		} forEach _muzzles;	
	};        
	  
	{
		if(_x != "") then {
			_magazine = _x;
			_target addMagazine _magazine;
			waitUntil { {_magazine == toLower(_x) } count (magazines _target) > 0 };
		};
	} forEach _magazines; // add all default primery weapon magazines
							
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
	if(count _loadedMagazines > 0) then {
		_magazine = toLower(_loadedMagazines select 1);
	} else {   
		_magazine = toLower(getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0);
	};
	if(_magazine != "") then {
		_target addMagazine _magazine;
		waitUntil { {_magazine == toLower(_x) } count (magazines _target) > 0 };
	};
	
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
	if(count _loadedMagazines > 0) then {
		_magazine = toLower(_loadedMagazines select 2);
	} else {
		_magazine = toLower(getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0);
	};
	if(_magazine != "") then {
		_target addMagazine _magazine;
		waitUntil { {_magazine == toLower(_x) } count (magazines _target) > 0 };
	};
	
	_target addWeapon _weapon;
	{ if(_x!="") then { _target addSecondaryWeaponItem _x; }; } foreach (_data select 6);
	
	if(!_selectedWeapon) then {
		_target selectWeapon _weapon;
		_selectedWeapon = true;  
	};
};


if(count _data > 14) then {
	_weapon = _data select 14;
	if(_target hasWeapon _weapon) then {
		_target selectWeapon _weapon;
	};
};


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


_outfit = _data select 9; 
if(_outfit != "") then {
	_target addVest _outfit;
	waitUntil { vest _target == _outfit };
	{ [_target,_x] call _add; } foreach (_data select 10);
	if(getText(configFile>>"CfgWeapons">>_outfit>>"ItemInfo">>"containerclass")!="Supply0") then { // fix for rebreather having no space
		while { loadVest _target < 1 } do {
			_target addItem "ItemWatch";
			_placeholderCount = _placeholderCount + 1;
		};
	};
};      
 

_add = {
	private ["_target","_item"];
	_target = _this select 0;
	_item = _this select 1;
	if(isClass(configFile>>"CfgMagazines">>_item)) then {
		unitBackpack _target addMagazineCargo [_item,1];
		} else {
			if(getNumber(configFile>>"CfgVehicles">>_item>>"isbackpack")==1) then {
			unitBackpack _target addBackpackCargo [_item,1];  
			} else {
			if(isClass(configFile>>"CfgWeapons">>_item>>"WeaponSlotsInfo") && getNumber(configFile>>"CfgWeapons">>_item>>"showempty")==1) then {
				unitBackpack _target addWeaponCargo [_item,1];  
			} else {
				_target addItem _item;         
			};
		};
	};
};     

removeBackpack _target;
_outfit = _data select 11; 
if(_outfit != "") then {
	_target addBackpack _outfit;
	waitUntil { backpack _target == _outfit };                                                                    
	clearAllItemsFromBackpack _target;
	{ [_target, _x] call _add; } foreach (_data select 12);
};


// remove placeholders
for "_i" from 1 to _placeholderCount do {
	_target removeItem "ItemWatch"; 
};


_target setPos (getPos _target);
