/*

	AUTHOR: aeroson
	NAPATH_ME: loadout_manager.sqf
	VERSION: 1.1
	
	DOWNLOAD, DOCUPATH_MENTATION & PARTICIPATE:
	https://github.com/aeroson/get-set-loadout
	http://forums.bistudio.com/showthread.php?148577-GET-SET-Loadout-(saves-and-loads-pretty-much-everything)
	
	REQUIRES:
	requires compiled set/get functions (usually in the mission's init.sqf) 
	getLoadout = compile preprocessFileLineNumbers 'fnc_get_loadout.sqf';
	setLoadout = compile preprocessFileLineNumbers 'fnc_set_loadout.sqf';
	
	USAGE:
	put this into init line of object you wish to be loadout manager
	0 = [this] execVM 'loadout_manager.sqf';
	
*/	
// CONNECTORS:
#define FUNC_getLoadout getLoadout
#define FUNC_setLoadout setLoadout
#define PATH_ME "loadout_manager.sqf"
	

if (isDedicated) exitWith {};

private["_obj","_vasAdd","_actions","_args","_removeActions","_mainMenu","_loadout","_arg1","_version"];

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
	call _removeActions;
	_loadout = profileNamespace getVariable "aero_loadout";
	if !isNil("_loadout") then {
		_any = false;
		for "_i" from 0 to count(_loadout) do {
			_l = _loadout select _i;
			if !isNil("_l") then {
				_any = true;		
				_actions = _actions + [_obj addAction [format["<t color='#00cc00'>Load </t><t color='#ffffff' size='1.5'>%1</t>",_l select 0], PATH_ME, ["load",_i], 3000-_i]];
			};
		};
		if _any then {
			_actions = _actions + [ _obj addAction ["<t color='#ff1111'>Remove loadout ...</t>", PATH_ME, ["remove_menu"], 2004] ];
		};
	};
	_actions = _actions + [ _obj addAction ["<t color='#ff8822'>Save loadout ...</t>", PATH_ME, ["save_menu"], 2008] ];
	_actions = _actions + [ _obj addAction ["<t color='#0099ee'>Offer loadout ...</t>", PATH_ME, ["offer_menu"], 2002] ];
	
	_any = false;
	for "_i" from 0 to 9 do {
		if(!isnil {profileNameSpace getVariable format["vas_gear_new_%1",_i]}) then {
			_any = true;
		};
	};      	
	for "_i" from 0 to 9 do {
		if(!isnil {profileNameSpace getVariable format["vas_gear_%1",_i]}) then {
			_any = true;
		};
	};
	if(_any) then {	
		_actions = _actions + [ _obj addAction ["<t color='#0099ee'>Load VAS loadout ...</t>", PATH_ME, ["vas_menu"], 2000] ];
	};
};
 

_vasAdd = {
	private ["_target","_item"];
	_target = _this select 0;
	_item = _this select 1;
	if(isClass(configFile>>"CfgMagazines">>_item)) then {
		_target addMagazine _item;
	} else {
		if(isClass(configFile>>"CfgWeapons">>_item>>"WeaponSlotsInfo")&&getNumber(configFile>>"CfgWeapons">>_item>>"showempty")==1) then {
			if(!isNull unitBackpack _target) then {
				unitBackpack _target addWeaponCargo [_item,1];
			};
		} else {
			_target addItem _item;				 
		};
	};
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

_arg1 = _args select 1;
_loadout = profileNamespace getVariable "aero_loadout";

if isNil("_loadout") then 
{
	profileNamespace setVariable ["aero_loadout",[]];
};


switch (_args select 0) do {
 
	case "back": {
	
		call _mainMenu;

	};
	

	case "save_menu": {
	
		call _removeActions;		
		_actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", PATH_ME, ["back"], 3001, false, false]];
		_actions = _actions + [_obj addAction ["<t color='#ffcc66'>Save as new</t>", PATH_ME, ["save",-1], 3000]];
		
		for "_i" from 0 to (count(_loadout)-1) do {
			_l = _loadout select _i;
			if !isNil("_l") then {		
				_actions = _actions + [_obj addAction [format["<t color='#ff8822'>Replace </t><t color='#ffffff' size='1.5'>%1</t>",_l select 0], PATH_ME, ["save",_i], 2000-_i]];
			};
		};
		
	};
	
	
	case "remove_menu": {
	
		call _removeActions;		
		_actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", PATH_ME, ["back"], 3000, false, false]];
			
		for "_i" from 0 to (count(_loadout)-1) do {
			_l = _loadout select _i;
			if !isNil("_l") then {		
				_actions = _actions + [_obj addAction [format["<t color='#ff1111'>Remove </t><t color='#ffffff' size='1.5'>%1</t>",_l select 0], PATH_ME, ["remove",_i], 2000-_i]];
			};
		};
	
	};
	
	
	case "remove": {
		 
		// set desired loadout at index to nil (remove it)
		_loadoutName = (_loadout select _arg1) select 0;
		hint parseText format["<t size='1' color='#ff1111'>Removed loadot</t>"];
		_loadout set[_arg1, nil];
		profileNamespace setVariable ["aero_loadout",_loadout];
		
		call _mainMenu;	 
		
	};


	case "save": {

		// find empty loadout index
		if (_arg1==-1) then {
			_i = 0;
			while {_i<=count(_loadout)} do {
				_l = _loadout select _i;
				if isNil("_l") then {
					_arg1 = _i;
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
			_arg1,
			[	 
				_loadoutName,		 
				[_target] call FUNC_getLoadout 
			]
		]; 
			
		profileNamespace setVariable ["aero_loadout",_loadout];
		saveProfileNamespace;
		hint parseText format["<t size='1' color='#ff8822'>Saved loadout</t>"];
		call _mainMenu;	

	};
	
	
	case "load": {
	 
		_loadout = _loadout select _arg1;		
		if ( isNil("_loadout") ) then {		
			hint "This loadout is empty !";			
		} else {		 
			_loadoutName = _loadout select 0;
			hint parseText format["<t size='1' color='#00cc00'>Loading loadout</t>"];			
			[_target, _loadout select 1] call FUNC_setLoadout;
			loadout = _loadout select 1; // to work with spawn loadout loading						 
			hint parseText format["<t size='1' color='#00cc00'>Loaded loadout</t>"];
			//hint parseText format["<t size='1' color='#00cc00'>Loaded</t><br /><br /><t size='6'>%1</t>",_loadoutName];			
		}; 
			 
	};
	
	
	case "offer_menu": {
	
		call _removeActions;
		_actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", PATH_ME, ["back"], 3001, false, false]];
		_actions = _actions + [_obj addAction ["<t color='#cc5555'>Refresh ...</t>", PATH_ME, ["offer_menu"], 3000, false, false]];
		
		_i = 0;
		{
			if (isPlayer _x) then {
				_actions = _actions + [_obj addAction [format["<t color='#0099ee'>Offer to %1</t>", name _x], PATH_ME, ["offer",_x], 2000-_i]];
			};
			_i = _i + 1;
		} forEach nearestObjects [getPos _target, ["CAManBase"], 5];
		
	};
	
	
	case "offer": {
	
		if (_target distance _arg1 > 5) then {
			hint "Too far, refresh and try again";
		} else {
			offer_loadout = [_target, [_target] call FUNC_getLoadout];
			(owner _arg1) publicVariableClient "aero_offer_loadout";
			hint format["Loadout offered to %1", name _arg1];
			call _mainMenu;
		};
		
	};
	 
	 
	case "vas_menu": {
	
		call _removeActions;
		_actions = _actions + [_obj addAction ["<t color='#cccccc'>... back</t>", PATH_ME, ["back"], 3000, false, false]];
			
		for "_i" from 0 to 9 do {
			if(!isnil {profileNameSpace getVariable format["vas_gear_new_%1",_i]}) then {
				_loadout = profileNameSpace getVariable format["vas_gear_new_%1",_i];				
				_actions = _actions + [_obj addAction [format["<t color='#0099ee'>Load %1</t>", _loadout select 0], PATH_ME, ["vas_load_new",_i], 2000-_i]];
			};
		};
		
		for "_i" from 0 to 9 do {
			if(!isnil {profileNameSpace getVariable format["vas_gear_%1",_i]}) then {
				_loadout = profileNameSpace getVariable format["vas_gear_%1",_i];				
				_actions = _actions + [_obj addAction [format["<t color='#0088ee'>Load %1</t>", _loadout select 0], PATH_ME, ["vas_load",_i], 1000-_i]];
			};
		};
		
	};
	

	case "vas_load_new": {
	 
		_l = profileNameSpace getVariable format["vas_gear_new_%1",_arg1];		
		_loadoutName = _l select 0;
		hint parseText format["<t size='1' color='#0099ee'>Loading VAS loadout</t>"];

/*
0	"drhdrhdrh",
1	"LMG_Mk200_ARCO_bipod_F",
2	"launch_NLAW_F",
3	"hgun_P07_F",
4 ["HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","SmokeShellGreen","SmokeShellGreen","SmokeShellGreen","SmokeShellYellow","SmokeShellYellow","SmokeShellYellow","SmokeShellYellow","SmokeShellPurple","SmokeShellPurple","SmokeShellPurple","SmokeShellPurple","SmokeShellBlue","SmokeShellBlue","SmokeShellBlue","SmokeShellBlue","SmokeShellBlue","SmokeShellOrange","SmokeShellOrange","SmokeShellOrange","SmokeShellOrange","SmokeShellOrange","SmokeShell","SmokeShell","SmokeShell","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","DemoCharge_Remote_Mag","200Rnd_65x39_cased_Box_Tracer","200Rnd_65x39_cased_Box_Tracer","200Rnd_65x39_cased_Box","DemoCharge_Remote_Mag","200Rnd_65x39_cased_Box","16Rnd_9x21_Mag","200Rnd_65x39_cased_Box","NLAW_F","16Rnd_9x21_Mag"],
5	"U_B_CombatUniform_mcam",
6 "V_PlateCarrierGL_rgr",
7 "B_Kitbag_mcamo",		
8	["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","G_Tactical_Clear","NVGoggles","H_HelmetB_paint","Binocular"],
9 ["muzzle_snds_H_MG","","optic_Arco"],
10 ["","",""]
11 ["muzzle_snds_L","",""],
12 [],
13 ["FirstAidKit","FirstAidKit"],
14 ["FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit"]
]*/

/*
 
_primary = _loadout select 1;
_launcher = _loadout select 2;
_handgun = _loadout select 3;
_magazines = _loadout select 4;
_uniform = _loadout select 5;
_vest = _loadout select 6;
_backpack = _loadout select 7;
_items = _loadout select 8;
_primitems = _loadout select 9;
_secitems = _loadout select 10;
_handgunitems = _loadout select 11;
_uitems = _loadout select 12;
_vitems = _loadout select 13;
_bitems = _loadout select 14;

*/
		
		[_target, 
			[
				_l select 8,
				
				_l select 1,
				_l select 9,
				
				_l select 3,
				_l select 11, 
				
				_l select 2,
				_l select 10,
				
				_l select 5,
				_l select 12,
				
				_l select 6,
				_l select 13,
				
				_l select 7,
				_l select 14
			]
		] call FUNC_setLoadout;		
	
		{
			[_target, _x] call _vasAdd; 
		} forEach (_l select 4);

		loadout = [_target] call FUNC_getLoadout; // to work with spawn loadout loading						 
		hint parseText format["<t size='1' color='#0099ee'>Loaded VAS loadout</t>"];

	};
	
	
	case "vas_load": {

		_l = profileNameSpace getVariable format["vas_gear_%1",_arg1];		
		_loadoutName = _l select 0;
		hint parseText format["<t size='1' color='#0088ee'>Loading VAS loadout</t>"];
		
/*		
0 _loadoutname ["mxm",
1 _primary "arifle_MXM_F",
2 _launcher "",
3 _handgun "hgun_Rook40_snds_F",
4 _magazines ["16Rnd_9x21_Mag","HandGrenade","HandGrenade","SmokeShellBlue","SmokeShellBlue","HandGrenade","SmokeShellBlue","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","SLAMDirectionalMine_Wire_Mag","SLAMDirectionalMine_Wire_Mag","SLAMDirectionalMine_Wire_Mag","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","SmokeShellBlue","SmokeShellBlue","SmokeShellBlue","SmokeShellBlue","SmokeShellBlue","DemoCharge_Remote_Mag","DemoCharge_Remote_Mag","SLAMDirectionalMine_Wire_Mag","SatchelCharge_Remote_Mag","DemoCharge_Remote_Mag","SLAMDirectionalMine_Wire_Mag","SLAMDirectionalMine_Wire_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","20Rnd_762x45_Mag","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade","HandGrenade"],
5 _uniform "U_B_CombatUniform_mcam_tshirt",
6	_vest "V_PlateCarrier2_rgr",
7	_backpack "B_Kitbag_mcamo",
8 _items ["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","G_Shades_Black","H_PilotHelmetHeli_B","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit","FirstAidKit"],
9 _primitems ["muzzle_snds_B","acc_flashlight","optic_Arco"],
10 _secitems [],
11 _handgunitems ["muzzle_snds_L","",""]]
*/

	a=_l;
	[_target, 
		[
			_l select 8,
			
			_l select 1,
			_l select 9,
			
			_l select 3,
			_l select 11, 
			
			_l select 2,
			_l select 10,
			
			_l select 5,
			[],
			
			_l select 6,
			[],
			
			_l select 7,
			[]
		]
	] call FUNC_setLoadout;
				
		{
		[_target, _x] call _vasAdd; 
	} forEach (_l select 4);

		loadout = [_target] call FUNC_getLoadout; // to work with spawn loadout loading						 
		hint parseText format["<t size='1' color='#0088ee'>Loaded VAS loadout</t>"];

	};
	



	default {
	
		hint "Invalid argument";
		
	};
	
	
	
};


_obj setVariable ["actions",_actions,false];
