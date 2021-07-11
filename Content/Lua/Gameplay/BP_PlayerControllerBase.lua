--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: BP_PlayerControllerBase
--- Date: 2021/7/11
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

local BP_PlayerControllerBase = {}

function BP_PlayerControllerBase:Initialize()
    print("BP_PlayerControllerBase:Initialize")
end

function BP_PlayerControllerBase:Construct()
    print("BP_PlayerControllerBase:Construct")
end

function BP_PlayerControllerBase:Destruct()
    print("BP_PlayerControllerBase:Destruct")
end

function BP_PlayerControllerBase:ReceiveBeginPlay()
    self.bCanEverTick = true
    -- set bCanBeDamaged property in parent
    self.bCanBeDamaged = false
    print("BP_PlayerControllerBase:ReceiveBeginPlay")
    self.Super:ReceiveBeginPlay()
end

function BP_PlayerControllerBase:ReceiveEndPlay(reason)
    print("BP_PlayerControllerBase:ReceiveEndPlay")
    self.Super:ReceiveEndPlay(reason)
end

return BP_PlayerControllerBase