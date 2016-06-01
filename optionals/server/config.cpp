#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"ace_common"};
        author = ECSTRING(common,ACETeam);
        authors[] = {"Glowbal"};
        PBO_URL;
        VERSION_CONFIG;
    };
};

class ACE_ServerSettings {
    #include "\userconfig\ace\serverconfig.hpp"
};
