/*
	Author: Andrew Gregory - EpochMod.com

    Contributors:

	Description:
	Switch player camera to antagonist. Currently only for use after player death. Return to player body when finished or revived.

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/master/Sources/epoch_code/compile/functions/EPOCH_fnc_playerAttachToAntagonist.sqf

    Example:
    [_antagonistObj,_plyrObj] call EPOCH_fnc_playerAttachToAntagonist;

    Parameter(s):
	_this select 0: OBJECT - Antagonist Object
	_this select 1: OBJECT - Player Object
	
	Returns:
	
*/
params ["_player", "_antagonist", "_bomb","_killer"];
private _tapDiag = "TapOut";
if (visibleMap) then {openMap [false, true];};
_antagonist switchCamera "Internal";
if(isNil "_bomb")then{_bomb = objNull;};
if(typeOf _antagonist == "Epoch_Sapper_F" || typeOf _antagonist == "Epoch_SapperB_F")then{_tapDiag = "TapOut3";};
createDialog _tapDiag;

diag_log format["Epoch: DEBUG: Attaching player %1 to %2, bomb found: %3",_player,_antagonist,_bomb];
[_antagonist,_tapDiag,_player,_killer] spawn{
_antagonist2 = _this select 0;
_tapDiag2 = _this select 1;
_player2 = _this select 2;
_killer2 = _this select 3;
private _doingGroan = false;
private _doingBoom = false;
private _groanTime = diag_tickTime;
	while {!alive _player2} do {
		if (playerRespawnTime <= 1) exitWith{ (findDisplay 46) closeDisplay 0; };
		if (playerRespawnTime > 15 && !dialog) then {createDialog _tapDiag2;};
		if (isObjectHidden _player2) exitWith {[_player2,Epoch_personalToken,_killer2, "EPOCH_antagObj", objNull, true] remoteExec ["EPOCH_server_playerSetVariable",2];closeDialog 2;};//revivial
		if((!alive _antagonist2)) exitWith {
		[_player2,Epoch_personalToken,_killer2, "EPOCH_antagObj", objNull, true] remoteExec ["EPOCH_server_playerSetVariable",2];
		uiSleep 3;(findDisplay 46) closeDisplay 0;};
		if(_player2 getVariable["EPOCH_callGroan",false])then{
		_player2 setVariable["EPOCH_callGroan",false];
		_doingGroan = true;
		_groanTime = diag_tickTime;
		[_player2,Epoch_personalToken,_killer2, "EPOCH_callGroan", true, false] remoteExec ["EPOCH_server_playerSetVariable",2];
		};
		if(_player2 getVariable["EPOCH_callBoom",false])then{
		_player2 setVariable["EPOCH_callBoom",false];
		_doingBoom = true;
		[_player2,Epoch_personalToken,_killer2, "EPOCH_callBoom", true, false] remoteExec ["EPOCH_server_playerSetVariable",2];
		};
		if(_doingGroan && ctrlEnabled 1602)then{ctrlEnable[1602,false];};
		if(_doingGroan && !(ctrlEnabled 1602) && diag_tickTime - _groanTime > 16)then{ctrlEnable[1602,true];_doingGroan=false;};
		if(_doingBoom && ctrlEnabled 1601)then{ctrlEnable[1601,false];};
		uiSleep 0.1;
	};
};