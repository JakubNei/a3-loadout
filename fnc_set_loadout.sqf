/*

	AUTHOR: aeroson
	NAME: fnc_set_loadout.sqf
	VERSION: 3.7
	
	DOWNLOAD & PARTICIPATE:
	https://github.com/aeroson/get-set-loadout
	http://forums.bistudio.com/showthread.php?148577-GET-SET-Loadout-(saves-and-loads-pretty-much-everything)
	
	PARAMETER(S):
	0 : target unit
	1 : array of strings/arrays containing desired target unit's loadout, obtained from fnc_get_loadout.sqf
	2 : (optional, default []) options : ["ammo"]  will allow loading of partially emptied magazines, otherwise magazines will be full 	 	
	
	addAction support:
	Sets player's loadout from global var loadout
  
*/

private ["_target","_loadMagsAmmo","_data","_loadedMagazines","_placeholderCount","_add","_outfit","_weapon","_muzzles","_magazines","_magazine","_currentWeapon","_currentMode"];

_loadMagsAmmo = false;

// addAction support
if(count _this < 4) then {
	_target = _this select 0;
	_data = _this select 1;
	if(count _this > 2) then {
		_loadMagsAmmo = "ammo" in (_this select 2);
	};
} else {
	_target = player;
	_data = loadout;
	//playSound3D ["A3\Sounds_F\sfx\ZoomIn.wav", _target]; 
};
a=_data;

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

_currentWeapon = "";
if(count _data > 14) then {
	_currentWeapon = _data select 14;
};
_currentMode = ""; 
if(count _data > 15) then {
	_currentMode = _data select 15;
};	

_placeholderCount = 0;

// basic add function intended for use with uniform and vest
_add = {
	private ["_target","_item"];
	_target = _this select 0;
	_item = _this select 1;
	if(typename _item == "ARRAY") then {
		if(_item select 0 != "") then {
			if(_loadMagsAmmo) then {
				_target addMagazine _item;
			} else {
				_target addMagazine (_item select 0);
			};
		};
	} else {
		if(_item != "") then {
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
	};
};

// remove clothes to prevent incorrect mag loading
removeUniform _target;
removeVest _target;
removeBackpack _target;

_outfit = "B_Kitbag_mcamo"; // we need to add items somewhere before we can assign them
_target addBackpack _outfit;
//waitUntil { backpack _target == _outfit };

removeAllAssignedItems _target;

// add assigned items
{ 
	[_target,_x] call _add;
	_target assignItem _x;
} foreach (_data select 0);

// add primary weapon, add primary weapon loaded magazine, add primary weapon items
_target removeWeapon (primaryWeapon _target);
_weapon = _data select 1;      
if(_weapon != "") then {
	if(isClass(configFile>>"CfgWeapons">>_weapon)) then {
		if (_currentWeapon == "") then {
			_currentWeapon = _weapon;
		}; 
		_muzzles = getArray(configFile>>"CfgWeapons">>_weapon>>"muzzles"); 
		if(count _loadedMagazines > 0) then {
			_magazines = _loadedMagazines select 0; // get loaded magazines from saved loadout
		} else {          
			_magazines = [getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0]; // generate default magazines	
			{
				if (_x != "this") then {
					_magazines set [count _magazines, toLower(getArray(configFile>>"CfgWeapons">>_weapon>>_x>>"magazines") select 0)];
				};
			} forEach _muzzles;	
		};        	  
		{
			[_target, _x] call _add;
		} forEach _magazines; // add magazine for each primary weapon muzzle							
		_target addWeapon _weapon;                                                                                    
		{ 
			if(_x!="") then { 
				_target removeItemFromPrimaryWeapon _x 
			}; 
		} forEach (primaryWeaponItems _target);                                 
		{ 
			if(_x!="") then { 
				_target addPrimaryWeaponItem _x; 
			}; 
		} foreach (_data select 2);
	} else {
		systemchat format["%1 doesn't exist",_weapon];
		_currentWeapon = "";
	};                             											                                                                                               
};

// add handgun weapon, add handgun weapon loaded magazine, add handgun weapon items
_target removeWeapon (handgunWeapon _target);
_weapon =_data select 3;
if(_weapon != "") then {
	if(isClass(configFile>>"CfgWeapons">>_weapon)) then {
		if (_currentWeapon == "") then {
			_currentWeapon = _weapon;
		};
		if(count _loadedMagazines > 0) then {
			_magazine = _loadedMagazines select 1;
		} else {   
			_magazine = getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0;
		};
		[_target, _magazine] call _add;	
		_target addWeapon _weapon;
		{ 
			if(_x!="") then {
				_target addHandgunItem _x; 
			}; 
		} foreach (_data select 4);
	} else {
		systemchat format["%1 doesn't exist",_weapon];
		_currentWeapon = "";
	};
};
      
// add secondary weapon, add secondary weapon loaded magazine, add secondary weapon items		                                 
_target removeWeapon (secondaryWeapon _target);
_weapon = _data select 5;
if(_weapon != "") then {
	if(isClass(configFile>>"CfgWeapons">>_weapon)) then {
		if (_currentWeapon == "") then {
			_currentWeapon = _weapon;
		};
		if(count _loadedMagazines > 0) then {
			_magazine = _loadedMagazines select 2;
		} else {
			_magazine = getArray(configFile>>"CfgWeapons">>_weapon>>"magazines") select 0;
		};
		[_target, _magazine] call _add;	
		_target addWeapon _weapon;
		{ 
			if(_x!="") then {
				_target addSecondaryWeaponItem _x;
			}; 
		} foreach (_data select 6);
	} else {
		systemchat format["%1 doesn't exist",_weapon];
		_currentWeapon = "";
	};		
};

// select weapon and firing mode
if ( vehicle _target == _target ) then {
	if ( _currentWeapon != "" && _currentMode != "" ) then {
		_muzzles = 0;                                                                                                           
		while { (_currentWeapon != currentMuzzle _target || _currentMode != currentWeaponMode _target ) && _muzzles < 100 } do {
			_target action ["SWITCHWEAPON", _target, _target, _muzzles];
			_muzzles = _muzzles + 1;
		};
		if(_muzzles >= 100) then {
			systemchat format["mode %1 for %2 doesn't exist", _currentMode, _currentWeapon];
			_currentMode = "";		
		};
	};
} else {
	_currentMode = "";
};
if (_currentMode == "") then {
	_target selectWeapon _currentWeapon;
};

// add uniform, add uniform items and fill uniform with placeholders
_outfit = _data select 7;  
if(_outfit != "") then {
	_target addUniform _outfit;
	//waitUntil { uniform _target == _outfit };
	{ 
		[_target,_x] call _add; 
	} foreach (_data select 8);	
	while { loadUniform _target < 1 } do {
		_target addItem "ItemWatch";
		_placeholderCount = _placeholderCount + 1;
	};
};

// add vest, add vest items and fill vest with placeholders
_outfit = _data select 9; 
if(_outfit != "") then {
	_target addVest _outfit;
	//waitUntil { vest _target == _outfit };
	{ 
		[_target,_x] call _add;
	} foreach (_data select 10);
	if(getText(configFile>>"CfgWeapons">>_outfit>>"ItemInfo">>"containerclass")!="Supply0") then { // fix for rebreather having no space
		while { loadVest _target < 1 } do {
			_target addItem "ItemWatch";
			_placeholderCount = _placeholderCount + 1;
		};
	};
};      
 
// more complex add function intended for use with backpack
_add = {
	private ["_target","_item"];
	_target = _this select 0;
	_item = _this select 1;
	if(typename _item == "ARRAY") then {
		if(_item select 0 != "") then {
			if(_loadMagsAmmo) then {
				_target addMagazine _item;
			} else {
				_target addMagazine (_item select 0);
			};
		};
	} else {
		if(isClass(configFile>>"CfgMagazines">>_item)) then {
			_target addMagazine _item;
		} else {
			if(_item != "") then {
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
	};
};     


// add backpack and add backpack items
removeBackpack _target;
_outfit = _data select 11; 
if(_outfit != "") then {
	_target addBackpack _outfit;
	//waitUntil { backpack _target == _outfit };                                                                    
	clearAllItemsFromBackpack _target;
	{
		[_target, _x] call _add;
	} foreach (_data select 12);
};


// remove placeholders
for "_i" from 1 to _placeholderCount do {
	_target removeItem "ItemWatch"; 
};

if ( vehicle _target == _target ) then {
	_target switchMove "";
	_target setPos (getPos _target);
};
