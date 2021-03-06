diag_log "--  >> Loading Custom Markers for blckeagls Mission System";

blck_customMarkers = [];
blck_fnc_addCustomMarker = compileFinal  preprocessFileLineNumbers "\q\addons\custom_server\Compiles\CustomMarkers\GMS_fnc_addCustomMarker.sqf";

if (!isServer) exitWith{};

_modType = call blck_fnc_getModType;
if (_modType isEqualTo "Epoch") then
{
	[] execVM "\q\addons\custom_server\Compiles\CustomMarkers\CustomMarkers_Epoch.sqf";
};

if (_modType isEqualTo "Exile") then
{
	//[] execVM "\q\addons\custom_server\Compiles\CustomMarkers\CustomMarkers_Exile.sqf";
};

{
	/*
		for spawnMarker.sqf parameters are:
		_mArray params["_missionType","_markerPos","_markerLabel","_markerLabelType","_markerColor","_markerType"];
		_markerType params["_mShape","_mSize","_mBrush"];
	*/
	//  		[31086.898,0,29440.51],"ServerRule","Server Rules:","mil_triangle","ColorRed"],
	if (blck_debugON) then {diag_log format["[blckeagls] custom markers:: -- >> Adding marker %1",_x];};
	private _markerDefinitions = [_x select 1,_x select 0,_x select 2,"",_x select 4,_x select 3];
	[_markerDefinitions] execVM "debug\spawnMarker.sqf";
}forEach blck_customMarkers;

diag_log "[blckeagls] -- >> Custom Markers Loaded";
