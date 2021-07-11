--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: BP_GameStateBase
--- Date: 2021/7/11
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

local BP_GameStateBase = {}

function BP_GameStateBase:Initialize()
    print("BP_GameStateBase:Initialize")
end

function BP_GameStateBase:Construct()
    print("BP_GameStateBase:Construct")
end

function BP_GameStateBase:Destruct()
    print("BP_GameStateBase:Destruct")
end

function BP_GameStateBase:ReceiveBeginPlay()
    self.bCanEverTick = true
    -- set bCanBeDamaged property in parent
    self.bCanBeDamaged = false
    print("BP_GameStateBase:ReceiveBeginPlay")
    self.Super:ReceiveBeginPlay()
end

function BP_GameStateBase:ReceiveEndPlay(reason)
    print("BP_GameStateBase:ReceiveEndPlay")
    self.Super:ReceiveEndPlay(reason)
end

return BP_GameStateBase