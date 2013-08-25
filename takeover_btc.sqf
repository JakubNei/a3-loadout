/*

	AUTHOR: aeroson (github.com/aeroson/a3-loadout)
	NAME: takeover_btc.sqf
	
	FOR BTC VERSION: 0.92

	DESCRIPTION:
	takes over BTC revive gear/loadout set/get functions
	now it saves/loads loadouts perfectly
	http://forums.bistudio.com/showthread.php?148085-BTC-Revive 
	
	REQUIRES:
	in client's init:
	getLoadout = compile preprocessFileLineNumbers 'get_loadout.sqf';
	setLoadout = compile preprocessFileLineNumbers 'set_loadout.sqf';
	
	USAGE:
	execVM 'takeover_btc.sqf'	

*/

waitUntil{
	!isNil{getLoadout} && !isNil{setLoadout} &&
	!isNil{BTC_get_gear} && !isNil{BTC_set_gear}
};  

BTC_get_gear = {
	[player, ["ammo"]] call getLoadout
};
BTC_gear = [] call BTC_get_gear;
 
BTC_set_gear = {
    [_this select 0, _this select 1, ["ammo"]] call setLoadout;
};
