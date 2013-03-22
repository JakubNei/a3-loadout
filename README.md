These scripts allows you set/get all of the unit's gear, including:
 - uniform
 - uniform contents
 - vest
 - vest contents
 - backpack
 - backpack contents
 - all quiped items
 - and all three weapons with their attachments

It is very useful for saving/loading loadouts.
Uses workaround with placeholders to add vest items.
Doesn't use removeAllWeapons so no problems with grenades.


Usage:
[php]
waitUntil { !isNull player }; // Wait for player to initialize

// Saves loadout of player into var loadout
loadout=[player] call compile preprocessFileLineNumbers 'fnc_get_loadout.sqf';

// Sets player's loadout from var loadout
0=[player,loadout] execVM 'fnc_set_loadout.sqf';
[/php]


Here an example of usage within map's [B]init.sqf[/B], it does save loadout upon map's init and then loads it after respawn, you can also save/load loadout at every ammobox. [URL="http://ni.g6.cz/a3/init.sqf"]download[/URL]
[php]
waitUntil { !isNull player }; // Wait for player to initialize

// Compile scripts
getLoadout = compile preprocessFileLineNumbers 'fnc_get_loadout.sqf';
setLoadout = compile preprocessFileLineNumbers 'fnc_set_loadout.sqf';

// Lets wait 10 seconds, hopefully all crates will spawn by then
sleep 10;

// Save default loadout
loadout = [player] call getLoadout;

// Add save/load loadout actions to all ammo boxes
{
  _x addAction ["Save loadout", "fnc_get_loadout.sqf"];
  _x addAction ["Load loadout", "fnc_set_loadout.sqf"];
} forEach nearestObjects [getpos player,["ReammoBox","ReammoBox_F"],15000];
                                                     
// Load saved loadout on respawn
player addEventHandler ["Respawn", {
    [player,loadout] spawn setLoadout;
  }
];
[/php]


Another example of map's [B]init.sqf[/B], this one will make you respawn with same gear.
[php]
waitUntil { !isNull player }; // Wait for player to initialize

// Compile scripts
getLoadout = compile preprocessFileLineNumbers 'fnc_get_loadout.sqf';
setLoadout = compile preprocessFileLineNumbers 'fnc_set_loadout.sqf';
                                                
// Save loadout every 2 seconds
[] spawn {
  while{true} do {
    if(alive player) then {
      loadout = [player] call getLoadout;
    };
    sleep 2;  
  };
};

// Load saved loadout on respawn
player addEventHandler ["Respawn", {
    [player,loadout] spawn setLoadout;
  }
];
[/php]



For those struggling with file hierarchy

[IMG]http://i.imgur.com/ymyA6bs.png[/IMG]

Notice the description.ext file, you need that if you want respawn. Check out wiki for how-to. [URL="http://community.bistudio.com/wiki/Description.ext"]community.bistudio.com/wiki/Description.ext[/URL]


If your loadout is loaded but you can not use grenades try this
[php]
// Load saved loadout on respawn
player addEventHandler ["Respawn", {
    [] spawn {
      sleep 1; // If it still doest not work add more sleep D:
      [player,loadout] spawn setLoadout;
    };
  }
];
[/php]


You can tinker with profileNamespace for persistent loadouts
[php]
// Saves var loadout into profileNamespace, which is persistent
profileNamespace setVariable ["loadout",loadout];

// Loads loadout from profileNamespace into var loadout
loadout=profileNamespace getVariable "loadout";
[/php]
