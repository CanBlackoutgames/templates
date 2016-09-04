["score_boards start", "INFO", false] call omtk_log;

_handle = execVM "omtk\score_board\library.sqf";
waitUntil {isNull _handle};

call omtk_rollback_to_start_time;

if (isServer) then {
	_endHour   = OMTK_SB_DUREE_MISSION select 0;
	_endMinute = OMTK_SB_DUREE_MISSION select 1;
	_endSecond = OMTK_SB_DUREE_MISSION select 2;
	_omtk_mission_duration = 3600*_endHour + 60*_endMinute + _endSecond - 1;
	
	if (("OMTK_DURATION_OVERRIDE" call BIS_fnc_getParamValue) > 0) then {
		_override = ("OMTK_DURATION_OVERRIDE" call BIS_fnc_getParamValue);
		_omtk_mission_duration = _override - 1;
		_endHour   = floor (_override/3600);
		_endMinute = floor ((_override - (3600*_endHour)) / 60);
		_endSecond = _override - (3600*_endHour) - (60*_endMinute);
	};

	_initHour = floor daytime;
	_initMinute = floor ((daytime - _initHour) * 60);
	_initSecond = floor (((((daytime) - (_initHour))*60) - _initMinute)*60);

	_omtk_mission_endTime = (_initHour + _endHour)*3600 + (_initMinute + _endMinute)*60 + _initSecond + _endSecond;
	missionNamespace setVariable ["omtk_mission_endTime", _omtk_mission_endTime];

	_omtk_mission_endTime_hour = floor (_omtk_mission_endTime/3600);
	_omtk_mission_endTime_minute = floor ((_omtk_mission_endTime - (3600*_omtk_mission_endTime_hour)) / 60);
	_omtk_mission_endTime_second = _omtk_mission_endTime - (3600*_omtk_mission_endTime_hour) - (60*_omtk_mission_endTime_minute);

	_txtFormat = "%1h%2m";
	if (_omtk_mission_endTime_minute < 10) then {_txtFormat = "%1h0%2m"; };
	_end_time_txt = format [_txtFormat,_omtk_mission_endTime_hour,_omtk_mission_endTime_minute];
	_end_time_txt = format ["<t shadow='1' shadowColor='#CC0000'>End of mission : %1</t>", _end_time_txt];
	_end_time_txt = parseText _end_time_txt;
	
	_omtk_mission_end_time_txt = composeText [_end_time_txt];
	missionNamespace setVariable ["omtk_mission_end_time_txt",_omtk_mission_end_time_txt];
	publicVariable "omtk_mission_end_time_txt";
	
	// SCHEDULE EVENTS
	[omtk_sb_compute_scoreboard, [], _omtk_mission_duration] call KK_fnc_setTimeout;
	[omtk_sb_start_mission_end, [], _omtk_mission_duration+2] call KK_fnc_setTimeout;

	
	// OBJ
	_omtk_sb_objectives = [];
	_omtk_sb_scores = [0,0];
	_omtk_sb_flags = [];

	{
		_side = _x select 1;
		_type = _x select 2;
		_values = _x select 4;
		
		switch(_side) do {
			case "BLUEFOR":	{
				_x set [1, West];
				[_omtk_sb_objectives, _x] call BIS_fnc_arrayPush;
				[_omtk_sb_scores, false]  call BIS_fnc_arrayPush;
			};
			case "REDFOR":	{
				_x set [1, East];
				[_omtk_sb_objectives, _x] call BIS_fnc_arrayPush;
				[_omtk_sb_scores, false]  call BIS_fnc_arrayPush;
			};
			case "BLUEFOR+REDFOR":	{
				_x set [1, West];
				[_omtk_sb_objectives, _x] call BIS_fnc_arrayPush;
				[_omtk_sb_scores, false]  call BIS_fnc_arrayPush;
				_x2 = + _x;
				_x2 set [1, East];
				[_omtk_sb_objectives, _x2] call BIS_fnc_arrayPush;
				[_omtk_sb_scores, false]  call BIS_fnc_arrayPush;
			};
			default	{
				["camp inconnu pour la creation de l'objectif","ERROR",true] call omtk_log;
			};
		};
		
		if (_type == "FLAG") then {
			{
				_omtk_sb_flags	set [_x, false];
			} forEach _values;
		};
		
	} foreach OMTK_SB_LISTE_OBJECTIFS;
	
	missionNamespace setVariable ["omtk_sb_objectives", _omtk_sb_objectives];
	missionNamespace setVariable ["omtk_sb_scores", _omtk_sb_scores];
	missionNamespace setVariable ["omtk_sb_flags", _omtk_sb_flags];
	
	publicVariable "omtk_sb_scores";
	publicVariable "omtk_sb_objectives";
	publicVariable "omtk_sb_flags";
	
	_pupu = 0;
	missionNamespace setVariable ["omtk_sb_ready4result", _pupu];
	publicVariable "omtk_sb_ready4result";
};



if (hasInterface) then {
	
	// Display end mission time to client
	sleep 2;
	_omtk_mEnd = missionNamespace getVariable "omtk_mission_end_time_txt";

	if (!isNil "_omtk_mEnd") then {
		[_omtk_mEnd,0,0,10,2] spawn BIS_fnc_dynamicText;
	};
	
	sleep 30;

	_omtk_sb_objectives = missionNamespace getVariable "omtk_sb_objectives";

	_index = -1;
	{
		_index = _index + 1;
		_side = _x select 1;
		_type = _x select 2;
	
		if (side player == _side) then {
			switch(_type) do {
				case "ACTION":	{
					_tgt = _x select 4;
					_tgtType = typeName _tgt;
					if (_tgtType == "STRING") then {
						_tgt = missionNamespace getVariable [_tgt, nil];
					};
					_txt = "<t color='#0000FF'>" + (_x select 3) + "</t>";
					_dur = _x select 5;
					_ext = _x select 6;	
					_action = _tgt addAction[_txt, { call omtk_closeAction;}, [_dur, _ext, _index]];
				};
	
				case "ACTION_DISPUTEE":	{
				
				};
			};
		};
	} foreach _omtk_sb_objectives;

};

["score_boards end", "INFO", false] call omtk_log;
