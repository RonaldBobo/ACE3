#define DEBUG_MODE_FULL
#include "script_component.hpp"
TRACE_1("enter", _this);

#define __TRACKINTERVAL 0.1	// how frequent the check should be.
#define __LOCKONTIME 1.85	// Lock on won't occur sooner
#define __LOCKONTIMERANDOM 0.3	// Deviation in lock on time
#define __SENSORSQUARE 1	// Locking on sensor square side in angles

#define __ConstraintTop (((ctrlPosition __JavelinIGUITargetingConstrainTop) select 1) + ((ctrlPosition (__JavelinIGUITargetingConstrainTop)) select 3))
#define __ConstraintBottom ((ctrlPosition __JavelinIGUITargetingConstrainBottom) select 1)
#define __ConstraintLeft (((ctrlPosition __JavelinIGUITargetingConstrainLeft) select 0) + ((ctrlPosition (__JavelinIGUITargetingConstrainLeft)) select 2))
#define __ConstraintRight ((ctrlPosition __JavelinIGUITargetingConstrainRight) select 0)

#define __OffsetX ((ctrlPosition __JavelinIGUITargetingLineV) select 0) - 0.5
#define __OffsetY ((ctrlPosition __JavelinIGUITargetingLineH) select 1) - 0.5


private["_args", "_lastTick"];

// Reset arguments if we havnt rendered in over a second
_args = uiNamespace getVariable[QGVAR(arguments), [] ];
if( (count _args) > 0) then {
    _lastTick = _args select 0;
    if(diag_tickTime - _lastTick > 1) then {
        [] call FUNC(onOpticLoad);
    };
};

// Pull the arguments
_currentTarget = _args select 1;


// Find a target within the optic range
_newTarget = objNull;
		
_range = parseNumber (ctrlText __JavelinIGUIRangefinder);
if (_range > 50 && {_range < 2500}) then {
    _pos = positionCameraToWorld [0,0,_range];
    _targetArray = _pos nearEntities ["AllVehicles", _range/25];
    if (count (_targetArray) > 0) then {
        _newTarget = _targetArray select 0;
    };
};

if (isNull _newTarget) then {
    _newTarget = cursorTarget;
};

if ((velocity ACE_player) distance [0,0,0] > 0.5 && {cameraView == "GUNNER"} && {cameraOn == ACE_player}) then {	// keep it steady.
    ACE_player switchCamera "INTERNAL";
};

if (isNull _newTarget) then {
    // No targets found
    _currentTarget = objNull;

    __JavelinIGUISeek ctrlSetTextColor __ColorGray;
    __JavelinIGUINFOV ctrlSetTextColor __ColorGreen;
    __JavelinIGUITargetingConstrains ctrlShow false;
    __JavelinIGUITargetingGate ctrlShow false;
    __JavelinIGUITargetingLines ctrlShow false;
    
    ACE_player setVariable [QGVAR(currentTarget),nil, false];
    
    // Disallow fire
    //if (ACE_player ammo "Javelin" > 0 || {ACE_player ammo "ACE_Javelin_Direct" > 0}) then {ACE_player setWeaponReloadingTime //[player, "Javelin", 0.2];};	
} else {
    if (_newTarget distance ACE_player < 2500 && 
            {(call CBA_fnc_getFoV) select 1 > 7} && 
            { (currentVisionMode ACE_player == 2)}
    ) then {
    
        // THIS IS A PROPER LOCK
        _currentTarget = _newTarget;
        __JavelinIGUISeek ctrlSetTextColor __ColorGreen;
        __JavelinIGUINFOV ctrlSetTextColor __ColorNull;
        __JavelinIGUITargetingConstrains ctrlShow true;
        
        ACE_player setVariable[QGVAR(currentTarget), _currentTarget, false];
        ACE_player setVariable[QGVAR(currentTargetPos), getPosASL _currentTarget, false];

   } else { 
        // Something is wrong with our seek
        _currentTarget = objNull;

        __JavelinIGUISeek ctrlSetTextColor __ColorGray;
        __JavelinIGUINFOV ctrlSetTextColor __ColorGray;
        __JavelinIGUITargetingConstrains ctrlShow false;
        __JavelinIGUITargetingGate ctrlShow false;
        __JavelinIGUITargetingLines ctrlShow false;

        ACE_player setVariable [QGVAR(currentTarget),nil, false];
   };
   
};


TRACE_2("", _newTarget, _currentTarget);

_args set[0, diag_tickTime];
_args set[1, _currentTarget];

uiNamespace setVariable[QGVAR(arguments), _args ];