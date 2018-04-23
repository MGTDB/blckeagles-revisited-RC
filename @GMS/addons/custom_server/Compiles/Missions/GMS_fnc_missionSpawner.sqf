/*
	Dynamic Mission Spawner (over-ground missions)
	By Ghostrider GRG
	Copyright 2016
	
	--------------------------
	License
	--------------------------
	All the code and information provided here is provided under an Attribution Non-Commercial ShareAlike 4.0 Commons License.

	http://creativecommons.org/licenses/by-nc-sa/4.0/
*/
#include "\q\addons\custom_server\Configs\blck_defines.hpp";
#define delayTime 1
private ["_abort","_crates","_aiGroup","_objects","_groupPatrolRadius","_missionLandscape","_mines","_blck_AllMissionAI","_blck_localMissionMarker","_assetKilledMsg","_enemyLeaderConfig",
		"_AI_Vehicles","_timeOut","_aiDifficultyLevel","_missionPatrolVehicles","_missionGroups","_loadCratesTiming","_spawnCratesTiming","_assetSpawned","_hostageConfig",
		"_chanceHeliPatrol","_noPara","_chanceLoot","_heliCrew","_loadCratesTiming","_useMines","_blck_AllMissionAI","_delayTime","_groupPatrolRadius",
		"_wait","_missionStartTime","_playerInRange","_missionTimedOut","_temp","_patrolVehicles","_vehToSpawn","_noChoppers","_chancePara","_marker"];
		
params["_coords","_markerClass","_aiDifficultyLevel"];

////////
// set all variables needed for the missions
// data is pulled either from the mission description or from the _mission variable passsed as a parameter
// Deal with situations where some of these variables might not be defined as well.
////////

// _mission params["OrangeMarker","orange",blck_TMin_Orange,blck_TMax_Orange];
//_markerClass = _mission select 0;
// _aiDifficultyLevel = _mission select 1;

[_markerClass,  "active",_coords] call blck_fnc_updateMissionQue;
blck_ActiveMissionCoords pushback _coords; 
diag_log format["[blckeagls] missionSpawner (17):: Initializing mission: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];

if (isNil "_assetKilledMsg")			 then {_assetKilledMsg = ""};
if (isNil "_markerColor") 				then {_markerColor = "ColorBlack"};
if (isNil "_markerType") 				then {_markerType = ["mil_box",[]]};
//if (isNil "_timeOut") then {_timeOut = -1;};
if (isNil "_endCondition") 				then {_endCondition = blck_missionEndCondition};  // Options are "allUnitsKilled", "playerNear", "allKilledOrPlayerNear"};
if (isNil "_spawnCratesTiming")	 		then {_spawnCratesTiming = blck_spawnCratesTiming}; // Choices: "atMissionSpawnGround","atMissionStartAir","atMissionEndGround","atMissionEndAir". 
if (isNil "_loadCratesTiming") 			then {_loadCratesTiming = blck_loadCratesTiming}; // valid choices are "atMissionCompletion" and "atMissionSpawn"; 
if (isNil "_missionPatrolVehicles") 	then {_missionPatrolVehicles = []};
if (isNil "_missionGroups") 			then {_missionGroups = []};
if (isNil "_hostageConfig") 			then {_hostageConfig = []};
if (isNil "_enemyLeaderConfig") 		then {_enemyLeaderConfig = []};
if (isNil "_useMines") 					then {_useMines = blck_useMines;};
if (isNil "_weaponList") 				then {_weaponList = [_aiDifficultyLevel] call blck_fnc_selectAILoadout};
if (isNil "_sideArms") 					then {_sideArms = blck_Pistols};
if (isNil "_vests") 					then {_vests = blck_vests};
if (isNil "_backpacks") 				then {_backpacks = blck_backpacks};
//diag_log format["_fnc_missionSpawner: -> blck_backpacks = %1", blck_backpacks];
//diag_log format["_fnc_missionSpawner: -> _backpacks = %1",_backpacks];
if (isNil "_uniforms") 					then {_uniforms = blck_SkinList};
if (isNil "_headGear") 					then {_headgear = blck_headgear};

if (isNil "_chanceHeliPatrol") then
{
	switch (toLower(_aiDifficultyLevel)) do
	{
		case "blue": 	{_chanceHeliPatrol = blck_chanceHeliPatrolBlue};
		case "red": 	{_chanceHeliPatrol = blck_chanceHeliPatrolRed};
		case "green": 	{_chanceHeliPatrol = blck_chanceHeliPatrolGreen};
		case "orange": 	{_chanceHeliPatrol = blck_chanceHeliPatrolOrange};
		default 		{_chanceHeliPatrol = 0};
	};
};
if (isNil "_noChoppers") then
{
	switch (toLower(_aiDifficultyLevel)) do
	{
		case "blue": 	{_noChoppers = blck_noPatrolHelisBlue};
		case "red": 	{_noChoppers = blck_noPatrolHelisRed};
		case "green": 	{_noChoppers = blck_noPatrolHelisGreen};
		case "orange": 	{_noChoppers = blck_noPatrolHelisOrange};
		default 		{_noChoppers = 0};
	};
};
if (isNil "_chancePara") then
{
	switch (toLower (_aiDifficultyLevel)) do
	{
		case "blue": 	{_chancePara = blck_chanceParaBlue};
		case "red": 	{_chancePara = blck_chanceParaRed};
		case "green": 	{_chancePara = blck_chanceParaGreen};
		case "orange": 	{_chancePara = blck_chanceParaOrange};
		default 		{_chancePara = 0};
	};
};
if (isNil "_missionHelis") then
{
	switch (toLower (_aiDifficultyLevel)) do
	{
		case "blue":	{_missionHelis = blck_patrolHelisBlue};
		case "red":		{_missionHelis = blck_patrolHelisRed};
		case "green": 	{_missionHelis = blck_patrolHelisGreen};
		case "orange": 	{_missionHelis = blck_patrolHelisOrange};
		default			{_missionHelis = blck_patrolHelisBlue};
	};
};
if (isNil "_noPara") then
{
	switch (toLower (_aiDifficultyLevel)) do
	{
		case "blue": 	{_noPara = blck_noParaBlue};
		case "red": 	{_noPara = blck_noParaRed};
		case "green": 	{_noPara = blck_noParaGreen};
		case "orange": 	{_noPara = blck_noParaOrange};
		default 		{_noPara = 0};
	};
};
if (isNil "_chanceLoot") then {_chanceLoot = 1.0}; //0.5}; 
if (isNil "_paraTriggerDistance") then {_paraTriggerDistance = 400;};
if (isNil "_paraLoot") then {_paraLoot = blck_BoxLoot_Red};
if (isNil "_paraLootCounts") then {_paraLootCounts = blck_lootCountsRed};

_objects = [];
_mines = [];
_crates = [];
_aiGroup = [];
_missionAIVehicles = [];
_blck_AllMissionAI = [];
_AI_Vehicles = [];
_blck_localMissionMarker = [_markerClass,_coords,"","",_markerColor,_markerType];
#define delayTime 1
//_groupPatrolRadius = 50;

#ifdef blck_debugMode
diag_log "_missionSpawner:  All variables initialized";
#endif

if (blck_labelMapMarkers select 0) then
{
	//diag_log "labeling map markers *****";
	_blck_localMissionMarker set [2, _markerMissionName];
};
if !(blck_preciseMapMarkers) then
{
	//diag_log "Map marker will be OFFSET from the mission position";
	_blck_localMissionMarker set [1,[_coords,75] call blck_fnc_randomPosition];
};
_blck_localMissionMarker set [3,blck_labelMapMarkers select 1];  // Use an arrow labeled with the mission name?
[["start",_startMsg,_markerMissionName]] call blck_fnc_messageplayers;
_marker = [_blck_localMissionMarker] call blck_fnc_spawnMarker;

#ifdef blck_debugMode
if (blck_debugLevel > 0) then {diag_log "missionSpawner:: (145) message players and spawn a mission marker";};
if (blck_debugLevel > 0) then {diag_log format["missionSpawner:: (146) _marker = %1",_marker];};
if (blck_debugLevel > 0) then {diag_log "missionSpawner:: (147) waiting for player to trigger the mission";};
#endif
////////
//  All parameters are defined, lets wait until a player is nearby or the mission has timed out
////////

_missionStartTime = diag_tickTime;
_playerInRange = false;
_missionTimedOut = false;
_wait = true;

#ifdef blck_debugMode
if (blck_debugLevel > 0) then {diag_log "missionSpawner:: (90) starting mission trigger loop"};
#endif

while {_wait} do
{
	#ifdef blck_debugMode
	//diag_log "missionSpawner:: top of mission trigger loop";
	if (blck_debugLevel > 2) exitWith {_playerInRange = true;};
	#endif

	if ([_coords, blck_TriggerDistance, false] call blck_fnc_playerInRange) exitWith {_playerInRange = true;};
	if ([_missionStartTime] call blck_fnc_timedOut) exitWith {_missionTimedOut = true;};
	uiSleep 5;

	#ifdef blck_debugMode
	if (blck_debugLevel > 2) then
	{
		diag_log format["missionSpawner:: Trigger Loop - blck_debugLevel = %1 and _coords = %2",blck_debugLevel, _coords];
		diag_log format["missionSpawner:: Trigger Loop - players in range = %1",{isPlayer _x && _x distance2D _coords < blck_TriggerDistance} count allPlayers];
		diag_log format["missionSpawner:: Trigger Loop - timeout = %1", [_missionStartTime] call blck_fnc_timedOut];
	};
	#endif
};

if (_missionTimedOut) exitWith
{
	//  Deal with the case in which the mission timed out.
	blck_recentMissionCoords pushback [_coords,diag_tickTime]; 
	blck_ActiveMissionCoords = blck_ActiveMissionCoords - [ _coords];
	[_markerClass,  "inactive",[0,0,0]] call blck_fnc_updateMissionQue;
	blck_missionsRunning = blck_missionsRunning - 1;
	[_blck_localMissionMarker select 0] call blck_fnc_deleteMarker;
	[_objects, 0.1] spawn blck_fnc_cleanupObjects;
};

////////
// Spawn the mission objects, loot chest, and AI
////////
#ifdef blck_debugMode
if (blck_debugLevel > 0) then
{		
	diag_log format["[blckeagls] missionSpawner:: (200) --  >>  Mission tripped: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];
};
#endif

if (blck_SmokeAtMissions select 0) then  // spawn a fire and smoke near the crate
{
	_temp = [_coords,blck_SmokeAtMissions select 1] call blck_fnc_smokeAtCrates;
	if (typeName _temp isEqualTo "ARRAY") then 
	{
		_objects append _temp;
	};
};

uiSleep  delayTime;
if (_useMines) then
{
	_mines = [_coords] call blck_fnc_spawnMines;

};
uiSleep  delayTime;
_temp = [];

if (_missionLandscapeMode isEqualTo "random") then
{
	_temp = [_coords,_missionLandscape, 3, 15, 2] call blck_fnc_spawnRandomLandscape;
} else {
	params["_center","_objects"];
	_temp = [_coords, _missionLandscape] call blck_fnc_spawnCompositionObjects;
};
if (typeName _temp isEqualTo "ARRAY") then
{
	_objects append _temp;
};

#ifdef blck_debugMode
if (blck_debugLevel > 0) then
{
	diag_log format["[blckeagls] missionSpawner:: (237) Landscape spawned: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];
};
#endif

uiSleep  delayTime;;

_temp = [_coords,_missionLootVehicles] call blck_fnc_spawnMissionLootVehicles;
//uisleep 1;
_crates append _temp;

uiSleep  delayTime;

_abort = false;
_temp = [[],[],false];

// params["_coords",_minNoAI,_maxNoAI,_missionGroups,_aiDifficultyLevel,_uniforms,_headGear,_vests",_backpacks,_weapons,sideArms,_isScubaGroup];
#ifdef blck_debugMode
private _params = [_coords,_minNoAI,_maxNoAI,_missionGroups,_aiDifficultyLevel,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms];
{
	diag_log format["_fnc_missionSpawner: _param %1 label %2 = %3",_forEachIndex, _x, _params select _forEachIndex];
}forEach ["_coords","_minNoAI","_maxNoAI","_missionGroups","_aiDifficultyLevel","_uniforms","_headgear","_vests","_backpacks","_weaponList","_sideArms"];
#endif

_temp = [_coords, _minNoAI,_maxNoAI,_missionGroups,_aiDifficultyLevel,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms] call blck_fnc_spawnMissionAI;

#ifdef blck_debugMode
if  (blck_debugLevel > 2) then {
	diag_log format["missionSpawner :: (264) blck_fnc_spawnMissionAI returned a value of _temp = %1",_temp]; uiSleep 1;
};

_abort = _temp select 1;
if  (blck_debugLevel > 2) then {
	diag_log format["missionSpawner :: (269) blck_fnc_spawnMissionAI returned a value of _abort = %1",_abort]; uiSleep 1;
};
#endif

if (_abort) exitWith
{
	if (blck_debugLevel > 1) then {
		diag_log "missionSpawner:: (277) grpNull returned, mission termination criteria met, calling blck_fnc_endMission"
	};
	[_mines,_objects,_crates, _blck_AllMissionAI,_endMsg,_blck_localMissionMarker,_coords,_markerClass,  1] call blck_fnc_endMission;
};
if !(_abort) then 
{
	_blck_AllMissionAI append (_temp select 0);
};

#ifdef blck_debugMode
if (blck_debugLevel > 0) then
{
	diag_log format["[blckeagls] missionSpawner:: (288) AI Patrols Spawned: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];
};
#endif

_assetSpawned = objNull;
if !(_hostageConfig isEqualTo []) then
{
	_assetSpawned = [_coords,_hostageConfig] call blck_fnc_spawnHostage;
	//diag_log format["_fnc_missionSpawner: _assetSpawned = %1",_assetSpawned];
	_blck_AllMissionAI pushBack _assetSpawned;
};

if !(_enemyLeaderConfig isEqualTo []) then
{
	_assetSpawned = [_coords,_enemyLeaderConfig] call blck_fnc_spawnLeader;
	//diag_log format["_fnc_missionSpawner: _assetSpawned = %1",_assetSpawned];
	_blck_AllMissionAI pushBack _assetSpawned;
};

#ifdef blck_debugMode
	if  (blck_debugLevel >= 1) then {
		diag_log format["_fnc_missionSpawner: _assetSpawned = %1",_assetSpawned];
	};
#endif

uiSleep  delayTime;
_temp = [[],[],false];
_abort = false;

_vehToSpawn = [_noVehiclePatrols] call blck_fnc_getNumberFromRange;
if (blck_useVehiclePatrols && ((_vehToSpawn > 0) || count _missionPatrolVehicles > 0)) then
{
	#define useRelativePos true
	//params[_coords,_noVehiclePatrols,_aiDifficultyLevel,_missionPatrolVehicles,_useRelativePos,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms, _isScubaGroup];
	//_temp = [_coords,_vehToSpawn,_aiDifficultyLevel,_uniforms,_headGear,_missionPatrolVehicles] call blck_fnc_spawnMissionVehiclePatrols;
	_temp = [_coords,_vehToSpawn,_aiDifficultyLevel,_missionPatrolVehicles,useRelativePos,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms] call blck_fnc_spawnMissionVehiclePatrols;

	if (typeName _temp isEqualTo "ARRAY") then
	{
		_abort = _temp select 2;
	};
	if !(_abort) then
	{
		_patrolVehicles = _temp select 0;
		_blck_AllMissionAI append (_temp select 1);
	};
};

if (_abort) exitWith 
{
	[_mines,_objects,_crates, _blck_AllMissionAI,_endMsg,_blck_localMissionMarker,_coords,_markerClass,  1] call blck_fnc_endMission;
};

uiSleep  delayTime;
_temp = [[],[],false];
_abort = false;

//  Deal with helicopter patrols
_temp = [];

#ifdef blck_debugMode
if (blck_debugLevel > 1) then
{
	diag_log format["[blckeagls] missionSpawner:: (351) calling in heli patrol: Current mission: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];
};
#endif

_noChoppers = [_noChoppers] call blck_fnc_getNumberFromRange;
//_noPara = [_noPara] call blck_fnc_getNumberFromRange;

#ifdef blck_debugMode
if (blck_debugLevel > 1) then {diag_log format["_missionSpawner(322):: _noChoppers = %1  && _chancePara = %2",_noChoppers,_chancePara]};
#endif
if (_noChoppers > 0) then
{
	for "_i" from 1 to (_noChoppers) do
	{
		if (random(1) < _chanceHeliPatrol) then
		{
			//_temp = [_coords,_missionHelis,spawnHeli,_aiDifficultyLevel,_chancePara,_noPara,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms] call blck_fnc_spawnMissionReinforcements;
			_temp = [_coords,_aiDifficultyLevel,_missionHelis,_uniforms,_headGear,_vests,_backpacks,"none",_weaponList, _sideArms] call blck_fnc_spawnMissionHeli;

			if (typeName _temp isEqualTo "ARRAY") then
			{
				_abort = _temp select 2;
				blck_monitoredVehicles pushBack (_temp select 0);
				_blck_AllMissionAI append (_temp select 1);
			};
			if (_abort) then
			{
				_objects pushback (_temp select 0);
				[_mines,_objects,_crates, _blck_AllMissionAI,_endMsg,_blck_localMissionMarker,_coords,_markerClass,  1] call blck_fnc_endMission;
			};
		};
	};
};


//////////////////////////
// Spawn Crates and Emplaced Weapons Last to try to force them to correct positions relative to spawned buildinga or other objects.
#ifdef blck_debugMode
if (blck_debugLevel > 0) then {diag_log format["missionSpawner:: (389) preparing to spawn emplaced weapons for _coords %4 | _markerClass %3 | blck_useStatic = %1 | _noEmplacedWeapons = %2",blck_useStatic,_noEmplacedWeapons,_markerClass,_coords];};
#endif
uiSleep 15;
private["_noEmplacedToSpawn"];
_noEmplacedToSpawn = [_noEmplacedWeapons] call blck_fnc_getNumberFromRange;
diag_log format["_fnc_missionSpawner: -> _noEmplacedToSpawn = %1 | blck_useStatic = %2",_noEmplacedToSpawn,blck_useStatic];
if (blck_useStatic && (_noEmplacedToSpawn > 0)) then
{
	// _params = ["_coords","_missionEmplacedWeapons","_useRelativePos","_noEmplacedWeapons","_aiDifficultyLevel","_uniforms","_headGear","_vests","_backpacks","_weaponList","_sideArms"];
	// _temp = [_missionEmplacedWeapons,_noEmplacedToSpawn,_aiDifficultyLevel,_coords,_uniforms,_headGear] call blck_fnc_spawnEmplacedWeaponArray;
	_temp = [_coords,_missionEmplacedWeapons,useRelativePos,_noEmplacedToSpawn,_aiDifficultyLevel,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms] call blck_fnc_spawnEmplacedWeaponArray;
	
	if (typeName _temp isEqualTo "ARRAY") then
	{
		_abort = _temp select 2;
	};
	
	if !(_abort) then
	{
		_objects append (_temp select 0);
		_blck_AllMissionAI append (_temp select 1);
	};
};
if (_abort) exitWith 
{
	[_mines,_objects,_crates, _blck_AllMissionAI,_endMsg,_blck_localMissionMarker,_coords,_markerClass,  1] call blck_fnc_endMission;
};
uiSleep  delayTime;
if (_spawnCratesTiming isEqualTo "atMissionSpawnGround") then
{
	if (count _missionLootBoxes > 0) then
	{
		_crates = [_coords,_missionLootBoxes,_loadCratesTiming, _spawnCratesTiming, "start", _aiDifficultyLevel] call blck_fnc_spawnMissionCrates;
	}
	else
	{
		_crates = [_coords,[[selectRandom blck_crateTypes,[0,0,0],_crateLoot,_lootCounts]], _loadCratesTiming, _spawnCratesTiming, "start", _aiDifficultyLevel] call blck_fnc_spawnMissionCrates;
		
	};

	if (blck_cleanUpLootChests) then
	{
		_objects append _crates;
	};
};
if (_noPara > 0 && (random(1) < _chancePara) && _paraTriggerDistance == 0) then
{
	diag_log format["_fnc_missionSpawner (436):  spawning %1 paraunits at mission spawn",_noPara];
	private _paratroops = [_coords,_noPara,_aiDifficultyLevel,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms] call blck_fnc_spawnParaUnits;
	if !(isNull _paratroops) then 
	{
		_blck_AllMissionAI append (units _paratroops);
	};
	if (random(1) < _chanceLoot) then
	{
		diag_log format["_fnc_missionSpawner (446): spawning supplemental loot with _chanceLoot = %1",_chanceLoot];
		private _extraCrates = [_coords,[[selectRandom blck_crateTypes,[0,0,0],_paraLoot,_paraLootCounts]], "atMissionSpawn","atMissionStartAir", "start", _aiDifficultyLevel] call blck_fnc_spawnMissionCrates;
		if (blck_cleanUpLootChests) then
		{
			_objects append _extraCrates;
		};		
	};
};

// Define Triggers for mission end
private["_missionComplete","_endIfPlayerNear","_endIfAIKilled","_secureAsset","_crateStolen","_locations"];
_missionComplete = -1;
_startTime = diag_tickTime;

switch (_endCondition) do
{
	case "playerNear": {_secureAsset = false; _endIfPlayerNear = true;_endIfAIKilled = false;};
	case "allUnitsKilled": {_secureAsset = false; _endIfPlayerNear = false;_endIfAIKilled = true;};
	case "allKilledOrPlayerNear": {_secureAsset = false; _endIfPlayerNear = true;_endIfAIKilled = true;};
	case "assetSecured": {_secureAsset = true; _endIfPlayerNear = false; _endIfAIKilled = false;};
};

if (blck_showCountAliveAI) then
{
	if !(_marker isEqualTo "") then
	{
		[_marker,_markerMissionName,_blck_AllMissionAI] call blck_fnc_updateMarkerAliveCount;
		blck_missionMarkers pushBack [_marker,_markerMissionName,_blck_AllMissionAI];
	};
};

_crateStolen = false;
_locations = [_coords];
private _spawnPara = if (random(1) < _chancePara) then {true} else {false};
diag_log format["_fnc_missionSpawner (477): _spawnPara = %1 | _chancePara = %2",_spawnPara,_chancePara];
{
	_locations pushback (getPos _x);
	_x setVariable["crateSpawnPos", (getPos _x)];
} forEach _crates;

while {_missionComplete isEqualTo -1} do
{
	if (blck_debugLevel isEqualTo 3) exitWith {uiSleep 180};
	if (_endIfPlayerNear) then
	{
		if ([_locations,10,true] call blck_fnc_playerInRangeArray) then {_missionComplete = 1};
	};
	if (_endIfAIKilled) then
	{
		if (({alive _x} count _blck_AllMissionAI) < 1) then {_missionComplete = 1};
	};
	if (_spawnCratesTiming isEqualTo "atMissionSpawn") then
	{
		{
			if ({[_x] call blck_fnc_crateMoved} count _crates > 0) exitWith
			{
				_missionComplete = 1;
				_crateStolen = true;
			};
		}forEach _crates;
	};
	if (_secureAsset) then
	{
		if !(alive _assetSpawned) then 
		{
			_missionComplete = 1
		} else {
			if (_assetSpawned getVariable["blck_AIState",0] > 0 && (({alive _x} count _blck_AllMissionAI) isEqualTo 1)) then {_missionComplete = 1};
		};
	};
	if (_spawnPara) then
	{
		
		if ([_coords,_paraTriggerDistance,true] call blck_fnc_playerInRange) then
		{
			_spawnPara = false; // The player gets one try to spawn these.
			if (random(1) < _chancePara) then  //  
			{
				private _paratroops = [_coords,_noPara,_aiDifficultyLevel,_uniforms,_headGear,_vests,_backpacks,_weaponList,_sideArms] call blck_fnc_spawnParaUnits;
				if !(isNull _paratroops) then 
				{
					_blck_AllMissionAI append (units _paratroops);
				};
				if (random(1) < _chanceLoot) then
				{
					private _extraCrates = [_coords,[[selectRandom blck_crateTypes,[0,0,0],_paraLoot,_paraLootCounts]], "atMissionSpawn","atMissionStartAir", "start", _aiDifficultyLevel] call blck_fnc_spawnMissionCrates;
					if (blck_cleanUpLootChests) then
					{
						_objects append _extraCrates;
					};		
				};	
			};
		};
	};
	uiSleep 2;
};

if (_crateStolen) exitWith
{
	diag_log format["missionSpawner:: (542) Crate Stolen Callening _fnc_endMission - > players near = %1 and ai alive = %2 and crates stolen = %3",[_locations,10,true] call blck_fnc_playerInRangeArray, {alive _x} count _blck_AllMissionAI, _crateStolen];
	[_mines,_objects,_crates, _blck_AllMissionAI,"Crate Removed from Mission Site Before Mission Completion: Mission Aborted",_blck_localMissionMarker,_coords,_markerClass,  2] call blck_fnc_endMission;
};

if ((_secureAsset) && !(alive _assetSpawned)) exitWith
{
	[_mines,_objects,_crates, _blck_AllMissionAI,_assetKilledMsg,_blck_localMissionMarker,_coords,_markerClass, 2] call blck_fnc_endMission;
};

if (_spawnCratesTiming in ["atMissionEndGround","atMissionEndAir"]) then
{
	if (count _missionLootBoxes > 0) then
	{
		_crates = [_coords,_missionLootBoxes,_loadCratesTiming,_spawnCratesTiming, "end", _aiDifficultyLevel] call blck_fnc_spawnMissionCrates;
	}
	else
	{
		_crates = [_coords,[[selectRandom blck_crateTypes,[0,0,0],_crateLoot,_lootCounts]], _loadCratesTiming,_spawnCratesTiming, "end", _aiDifficultyLevel] call blck_fnc_spawnMissionCrates;
	};
	
	#ifdef blck_debugMode
	if (blck_debugLevel > 0) then {diag_log format["_fnc_missionSpawner (531):  _crates = %1", _crates]};
	#endif
	
	if (blck_cleanUpLootChests) then
	{
		_objects append _crates;
	};

	#ifdef blck_debugMode
	if (blck_debugLevel > 0) then {diag_log format["[blckeagls] missionSpawner:: (428) Crates Spawned: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName]};
	#endif
};

if (_spawnCratesTiming isEqualTo "atMissionSpawnGround" && _loadCratesTiming isEqualTo "atMissionCompletion") then
{
	{
		[_x] call blck_fnc_loadMissionCrate;
	} forEach _crates;
};

#ifdef blck_debugMode
if (blck_debugLevel > 0) then
{
	diag_log format["[blckeagls] missionSpawner:: (586) Mission completion criteria fulfilled: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];
	diag_log format["missionSpawner :: (587) _endIfPlayerNear = %1 _endIfAIKilled= %2",_endIfPlayerNear,_endIfAIKilled];
	diag_log format["[blckeagls] missionSpawner:: (588) calling endMission: _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];
};
#endif

private["_result"];
// Force passing the mission name for informational purposes.
_blck_localMissionMarker set [2, _markerMissionName];
if (blck_showCountAliveAI) then
{
	_marker setMarkerText format["%1: All AI Dead",_markerMissionName];
	{
		if ((_x select 1) isEqualTo _markerMissionName) exitWith{blck_missionMarkers deleteAt _forEachIndex};
	}forEach blck_missionMarkers;
};

diag_log format["_fnc_missionSpawner (557) Build 123: _secureAsset = %1 | {alive _assetSpawned} = %2 | assetType = %3",_secureAsset,alive _assetSpawned, _assetSpawned getVariable["assetType",-1]];

if (_assetSpawned getVariable["assetType",0] isEqualTo 1) then
{
	diag_log "Processing Mission End for Hostage Rescue";
	_assetSpawned setCaptive false;
	_assetSpawned setVariable["GMSAnimations",[""],true];
	[_assetSpawned,""] remoteExec["switchMove",-2];;
	uiSleep 0.1;
	_assetSpawned enableAI "ALL";
	private _newPos = (getPos _assetSpawned) getPos [1000, random(360)];
	diag_log format["processing domove for hostage with current pos = %1 and new pos = %2",getPos _assetSpawned, _newPos];
	(group _assetSpawned) setCurrentWaypoint [group _assetSpawned, 0];
	[group _assetSpawned,0] setWaypointPosition [_newPos,0];
	[group _assetSpawned,0] setWaypointType "MOVE";
};

if (_assetSpawned getVariable["assetType",0] isEqualTo 2) then
{
	diag_log format["Processing Mission End for Arrest of Leader %1 with endAnimation %2",_assetSpawned,_assetSpawned getVariable["endAnimation",""]];
	[_assetSpawned,""] remoteExec["switchMove",-2];
	_assetSpawned setVariable["GMSAnimations",_assetSpawned getVariable["endAnimation",["AidlPercMstpSnonWnonDnon_AI"]],true];
	[_assetSpawned,selectRandom(_assetSpawned getVariable["endAnimation",["AidlPercMstpSnonWnonDnon_AI"]])] remoteExec["switchMove",-2];
};

diag_log format["_fnc_missionSpawner (579) Build 123: <calling blck_fnc_endMission> _secureAsset = %1 | {alive _assetSpawned} = %2 | assetType = %3",_secureAsset,alive _assetSpawned, _assetSpawned getVariable["assetType",-1]];

_result = [_mines,_objects,_crates,_blck_AllMissionAI,_endMsg,_blck_localMissionMarker,_coords,_markerClass,  0] call blck_fnc_endMission;

#ifdef blck_debugMode
if (blck_debugLevel > 2) then {diag_log format["[blckeagls] missionSpawner:: (507)end of mission: blck_fnc_endMission has returned control to _fnc_missionSpawner"]};
#endif
diag_log format["_fnc_missionSpawner (637) Mission Completed | _cords %1 : _markerClass %2 :  _aiDifficultyLevel %3 _markerMissionName %4",_coords,_markerClass,_aiDifficultyLevel,_markerMissionName];