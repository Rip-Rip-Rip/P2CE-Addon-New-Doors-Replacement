// Script created by Rip Rip Rip (https://youtube.com/@Rip-Rip-Rip)
const DOOR_MDL = "models/props/portal_door_combined.mdl"
const DOOR_SKIN_CLEAN_CLOSED = "0"
const DOOR_SKIN_CLEAN_OPEN = "1"
const DOOR_SKIN_DESTROYED_CLOSED = "3"
const DOOR_SKIN_DESTROYED_OPEN = "4"

function ScriptInit() {
    local canStartTimer = CreateEntityByName("logic_timer", {   // check every tick if entities have actually spawned in yet
        targetname = "newdoor_canstarttimer"
        RefireTime = 0.01
    })
    canStartTimer.ConnectOutput("OnTimer", "ScriptInit_CheckForStart")
    EntFire("newdoor_canstarttimer", "Enable")
}
function ScriptInit_CheckForStart() {   // if player exists, doors (probably) also exist, therefore swap doors
    if(GetPlayer() != null) {
        EntFire("newdoor_canstarttimer", "Kill")
        SwapDoors()
    }
}

function SwapDoors() {
    printl_dev("Attempting to swap doors...")

    local map = GetMapName()
    local mapPrefix = map.slice(0,6)    // used to check if a map is a1/a2
    local mapDestroyedBlocked = {   // force these maps to have clean doors no matter what
        ["sp_a2_trust_fling"] = true,
        ["sp_a2_bridge_intro"] = true,
        ["sp_a2_bridge_the_gap"] = true,
        ["sp_a2_turret_intro"] = true,
        ["sp_a2_laser_relays"] = true,
        ["sp_a2_laser_vs_turret"] = true,
        ["sp_a2_turret_blocker"] = true,
        ["sp_a2_column_blocker"] = true,
        ["sp_a2_laser_chaining"] = true,
        ["sp_a2_triple_laser"] = true,
        ["sp_a2_bts1"] = true
    }

    local mapIsDestroyed = ((mapPrefix == "sp_a1_" || mapPrefix == "sp_a2_") && !(map in mapDestroyedBlocked))
    printl_dev("Is the current map destroyed: " + mapIsDestroyed)

    for(local door = null; door = Entities.FindByModel(door, DOOR_MDL);) {
        if(door.GetClassname() == "phys_bone_follower") continue // internal part of prop_testchamber_door, continue to not waste work on something invisible

        if(mapIsDestroyed) {
            EntFireByHandle(door, "Skin", DOOR_SKIN_DESTROYED_CLOSED, 0.0, null, null)
            door.__KeyValueFromString("OnOpen", "!self,Skin," + DOOR_SKIN_DESTROYED_OPEN)
            door.__KeyValueFromString("OnClose", "!self,Skin," + DOOR_SKIN_DESTROYED_CLOSED)
        } else {
            door.__KeyValueFromString("OnOpen", "!self,Skin," + DOOR_SKIN_CLEAN_OPEN)
            door.__KeyValueFromString("OnClose", "!self,Skin," + DOOR_SKIN_CLEAN_CLOSED)
        }
    }
}

function printl_dev(msg) if(GetDeveloperLevel() > 0) printl("[DEVELOPER] " + msg)

ScriptInit()