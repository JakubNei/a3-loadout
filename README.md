#Arma 3 Get/Set Loadout
--

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

<br>
##Usage
Just an explanation on how it works.
```
// Saves loadout of player into var loadout
loadout=[player] call compile preprocessFileLineNumbers 'fnc_get_loadout.sqf';

// Sets player's loadout from var loadout
0=[player,loadout] execVM 'fnc_set_loadout.sqf';
```
<br>
Here an example of usage within map's init.sqf, it does save loadout upon map's init and then loads it after respawn, you can also save/load loadout at every ammobox.
```
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
    [player,loadout] call setLoadout;
  }
];
```
<br>
Another example of map's init.sqf, this one will make you respawn with same gear.
```
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
    [player,loadout] call setLoadout;
  }
];
```

<br>
##Fixes / Help
For those struggling with file hierarchy

![Alt text](http://i.imgur.com/ymyA6bs.png)

Notice the description.ext file, you need that if you want respawn. Check out wiki for how-to. [community.bistudio.com/wiki/Description.ext](http://community.bistudio.com/wiki/Description.ext#respawn)

<br>
If your loadout is loaded but you can not use grenades try this
```
// Load saved loadout on respawn
player addEventHandler ["Respawn", {
    [] spawn {
      sleep 1; // If it still doest not work add more sleep D:
      [player,loadout] call setLoadout;
    };
  }
];
```
<br>
You can tinker with profileNamespace for persistent loadouts
```
// Saves var loadout into profileNamespace, which is persistent
profileNamespace setVariable ["loadout",loadout];

// Loads loadout from profileNamespace into var loadout
loadout=profileNamespace getVariable "loadout";
```
