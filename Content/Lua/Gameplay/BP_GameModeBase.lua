--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: BP_GameModeBase
--- Date: 2021/7/11
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

package.cpath = package.cpath .. ';C:/Users/admin/AppData/Roaming/JetBrains/IntelliJIdea2021.1/plugins/EmmyLua/classes/debugger/emmy/windows/x64/?.dll'
local dbg = require('emmy_core')
dbg.tcpConnect('localhost', 9966)

local BP_GameModeBase = {}

function BP_GameModeBase:Initialize()
    print("BP_GameModeBase:Initialize")
end

function BP_GameModeBase:Construct()
    print("BP_GameModeBase:Construct")
end

function BP_GameModeBase:Destruct()
    print("BP_GameModeBase:Destruct")
end

function BP_GameModeBase:ReceiveBeginPlay()
    self.bCanEverTick = true
    -- set bCanBeDamaged property in parent
    self.bCanBeDamaged = false
    print("BP_GameModeBase:ReceiveBeginPlay")
    self.Super:ReceiveBeginPlay()
end

function BP_GameModeBase:ReceiveEndPlay(reason)
    print("BP_GameModeBase:ReceiveEndPlay")
    self.Super:ReceiveEndPlay(reason)
end

function BP_GameModeBase:K2_PostLogin(newPC)
    print("BP_GameModeBase:K2_PostLogin")
    self.Super:K2_PostLogin()

    local fire = slua.loadClass('/Game/BP_TestActor.BP_TestActor')
    local world = self:GetWorld()
    local p = FVector()
    for i = 0, 50000 do
        world:SpawnActor(fire, p, nil, nil)
    end
end

return BP_GameModeBase