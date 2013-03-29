/*

  AUTHOR: aeroson
  NAME: loadout_manager.sqf
  VERSION: 1
  
  REQUIRES:
  requires compiled set/get functions (usually in the mission's init.sqf) 
  getLoadout = compile preprocessFileLineNumbers 'fnc_get_loadout.sqf';
  setLoadout = compile preprocessFileLineNumbers 'fnc_set_loadout.sqf';
  
  DOWNLOAD & PARTICIPATE:
  https://github.com/aeroson/get-set-loadout
  http://forums.bistudio.com/showthread.php?148577-GET-SET-Loadout-(saves-and-loads-pretty-much-everything)
  
  USAGE:
  put this into init line of object you wish to be loadout manager
  0 = [this] execVM 'loadout_manager.sqf';
  
*/


if (isDedicated) exitWith {};

private["_obj","_actions","_args","_removeActions","_mainMenu","_loadout","_loadoutIndex","_version"];

_obj = _this select 0;


// remove all actions added by this script
_removeActions = {
  {
    _obj removeAction _x;
  } foreach _actions;
  _actions = [];
};


// show main menu
_mainMenu = {
  private ["_loadout","_any","_l"];
  _loadout = profileNamespace getVariable "aero_loadout";
  if !isNil("_loadout") then {
    _any = false;
    for "_i" from 0 to count(_loadout) do {
      _l = _loadout select _i;
      if !isNil("_l") then {
        _any = true;    
        _actions = _actions + [_obj addAction [format["<t color='#00cc00'>Load </t><t size='1.5'>%1</t>",_l select 0], "client\loadout\manager.sqf", ["load",_i], -2000+_i]];
      };
    };
    if _any then {
      _actions = _actions + [ _obj addAction ["<t color='#ff1111'>Remove loadout</t>", "client\loadout\manager.sqf", ["remove_menu"], -3001] ];
    };
  };
  _actions = _actions + [ _obj addAction ["<t color='#ff8822'>Save loadout</t>", "client\loadout\manager.sqf", ["save_menu"], -3000] ];
};
 


   
_target = player;

_args = ["back",0];
if (count(_this)>1) then {
  _args = _this select 3;
};

_actions = _obj getVariable "actions";
if isNil("_actions") then {
  _obj setVariable ["actions",[],false];
  _actions = [];
};

_loadoutIndex = _args select 1;
_loadout = profileNamespace getVariable "aero_loadout";

if isNil("_loadout") then 
{
  profileNamespace setVariable ["aero_loadout",[]];
};


switch (_args select 0) do {
 
  case "back": {
  
    call _removeActions;
    call _mainMenu;

  };
  

  case "save_menu": {
  
    call _removeActions;
    
    _actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", "loadout_manager.sqf", ["back"], -1000, false, false]];
    _actions = _actions + [_obj addAction ["<t color='#ffcc66'>Save as new</t>", "loadout_manager.sqf", ["save",-1], -1001]];
    
    for "_i" from 0 to (count(_loadout)-1) do {
      _l = _loadout select _i;
      if !isNil("_l") then {    
        _actions = _actions + [_obj addAction [format["<t color='#ff8822'>Replace </t><t size='1.5'>%1</t>",_l select 0], "loadout_manager.sqf", ["save",_i], -2000+_i]];
      };
    };
    
  };
  
  
  case "remove_menu": {
  
    call _removeActions;
    
    _actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", "loadout_manager.sqf", ["back"], -1000, false, false]];
      
    for "_i" from 0 to (count(_loadout)-1) do {
      _l = _loadout select _i;
      if !isNil("_l") then {    
        _actions = _actions + [_obj addAction [format["<t color='#ff1111'>Remove </t><t size='1.5'>%1</t>",_l select 0], "loadout_manager.sqf", ["remove",_i], -2000+_i]];
      };
    };
  
  };
  
  
  case "remove": {
  
    call _removeActions;
    
    // set desired loadout at index to nil (remove it)
    _loadoutName = (_loadout select _loadoutIndex) select 0;
    hint parseText format["<t size='1' color='#ff1111'>Removed loadot</t>"];
    _loadout set[_loadoutIndex, nil];
    profileNamespace setVariable ["aero_loadout",_loadout];
    
    call _mainMenu;   
    
  };


  case "save": {

    call _removeActions; 

    // find empty loadout index
    if (_loadoutIndex==-1) then {
      _i = 0;
      while {_i<=count(_loadout)} do {
        _l = _loadout select _i;
        if isNil("_l") then {
          _loadoutIndex = _i;
          _i = count(_loadout); // end loop     
        };
        _i = _i + 1;
      };
    };
    
    _loadoutName = 
      "<img image='"+getText(configFile>>"cfgweapons">>(primaryWeapon _target)>>"picture")+"'/>" +
      "<img image='"+getText(configFile>>"cfgweapons">>(handgunWeapon _target)>>"picture")+"'/>" +
      "<img image='"+getText(configFile>>"cfgweapons">>(secondaryWeapon _target)>>"picture")+"'/>" +
      "<img image='"+getText(configFile>>"cfgweapons">>(headgear _target)>>"picture")+"'/>" +
      "<img image='"+getText(configFile>>"cfgweapons">>(uniform _target)>>"picture")+"'/>" +
      "<img image='"+getText(configFile>>"cfgweapons">>(vest _target)>>"picture")+"'/>" +
      "<img image='"+getText(configFile>>"cfgvehicles">>(backpack _target)>>"picture")+"'/>";  
   
    hintSilent parseText format["<t size='1' color='#ff8822'>Saving loadout</t>"];   
     
    _loadout set
    [
      _loadoutIndex,
      [   
        _loadoutName,     
        [_target] call getLoadout 
      ]
    ]; 
      
    profileNamespace setVariable ["aero_loadout",_loadout];
    call _mainMenu;  
    hint parseText format["<t size='1' color='#ff8822'>Saved loadout</t>"];

  };
  

  
  case "load": {
   
    _loadout = _loadout select _loadoutIndex;    
    if ( isNil("_loadout") ) then {    
      hint "This loadout is empty !";      
    } else {     
      _loadoutName = _loadout select 0;
      hint parseText format["<t size='1' color='#00cc00'>Loading loadout</t>"];      
      [_target, _loadout select 1] spawn setLoadout;
      loadout = _loadout select 1; // to work with spawn loadout loading                
      hint parseText format["<t size='1' color='#00cc00'>Loaded loadout</t>"];
      //hint parseText format["<t size='1' color='#00cc00'>Loaded</t><br /><br /><t size='6'>%1</t>",_loadoutName];      
    }; 
       
  };
  

  default {
  
    hint "Invalid argument";
    
  };
  
  
  
};


_obj setVariable ["actions",_actions,false];
