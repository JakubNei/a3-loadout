/*

  AUTHOR: aeroson
  NAME: loadout_manager.sqf
  VERSION: 1
  
  REQUIRES:
  requres compiled set/get functions (just leave them in the mission's init.sqf)
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
  _loadout = profileNamespace getVariable "aero_loadout";
  if !isNil("_loadout") then {
    if (count(_loadout)>0) then {
      _actions = _actions + [ _obj addAction ["<t color='#ff1111'>Remove loadout</t>", "client\loadout\manager.sqf", ["remove_menu"], -3001] ];
    };
    for "_i" from 0 to count(_loadout) do {
      _l = _loadout select _i;
      if !isNil("_l") then {    
        _actions = _actions + [_obj addAction [format["<t color='#00cc00'>Load <t size='0.75'>%1</t></t>",_l select 0], "client\loadout\manager.sqf", ["load",_i], -2000+_i]];
      };
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
    
    _actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", "client\loadout\manager.sqf", ["back"], -1000, false, false]];
    _actions = _actions + [_obj addAction ["<t color='#ffcc66'>Save as new</t>", "client\loadout\manager.sqf", ["save",-1], -1001]];
    
    for "_i" from 0 to (count(_loadout)-1) do {
      _l = _loadout select _i;
      if !isNil("_l") then {    
        _actions = _actions + [_obj addAction [format["<t color='#ff8822'>Replace <t size='0.75'>%1</t></t>",_l select 0], "client\loadout\manager.sqf", ["save",_i], -2000+_i]];
      };
    };
    
  };
  
  
  case "remove_menu": {
  
    call _removeActions;
    
    _actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", "client\loadout\manager.sqf", ["back"], -1000, false, false]];
      
    for "_i" from 0 to (count(_loadout)-1) do {
      _l = _loadout select _i;
      if !isNil("_l") then {    
        _actions = _actions + [_obj addAction [format["<t color='#ff1111'>Remove <t size='0.75'>%1</t></t>",_l select 0], "client\loadout\manager.sqf", ["remove",_i], -2000+_i]];
      };
    };
  
  };
  
  
  case "remove": {
  
    call _removeActions;
    
    // set desired loadout at index to nil (remove it)
    hint parseText format["<t color='#ff1111'>Removed loadout<br /><br /><t size='0.9'>%1</t></t>",(_loadout select _loadoutIndex) select 0];
    _loadout set[_loadoutIndex, nil];
    profileNamespace setVariable ["aero_loadout",_loadout];
    
    call _mainMenu;   
    
  };


  case "save": {

    hint parseText format["<t color='#ff8822'>Saving loadout<br /><br /><br />"];
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
                  
    // determine loadout name    
    _loadoutName = getText(configFile>>"cfgWeapons">>(primaryWeapon _target)>>"displayname");
    if (_loadoutName=="") then {
      _loadoutName = getText(configFile>>"cfgWeapons">>(handgunWeapon _target)>>"displayname");
    };
    if (_loadoutName=="") then {
      _loadoutName = getText(configFile>>"cfgWeapons">>(secondaryWeapon _target)>>"displayname");
    };            
    _loadoutName = _loadoutName +" / "+getText(configFile>>"cfgWeapons">>(uniform _target)>>"displayname");
    
    if (backpack _target!="") then {    
      _loadoutName = _loadoutName +" / "+getText(configFile>>"cfgvehicles">>(backpack _target)>>"displayname");
    };
   
    hintSilent parseText format["<t color='#ff8822'>Saving loadout<br /><br /><t size='0.9'>%1</t></t>",_loadoutName];   
     
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
    hint parseText format["<t color='#ff8822'>Saved loadout<br /><br /><t size='0.9'>%1</t></t>",_loadoutName];

  };
  

  
  case "load": {
   
    _loadout = _loadout select _loadoutIndex;    
    if ( isNil("_loadout") ) then {    
      hint "This loadout is empty !";      
    } else {     
      hint parseText format["<t color='#00cc00'>Loading loadout<br /><br /><t size='0.9'>%1</t></t>",_loadout select 0];      
      [_target, _loadout select 1] call setLoadout;            
      hint parseText format["<t color='#00cc00'>Loaded loadout<br /><br /><t size='0.9'>%1</t></t>",_loadout select 0];      
    }; 
       
  };
  

  default {
  
    hint "Invalid argument";
    
  };
  
  
  
};


_obj setVariable ["actions",_actions,false];
