--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: BP_PlayerStateBase
--- Date: 2021/7/11
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

local BP_PlayerStateBase = {}

function BP_PlayerStateBase:Initialize()
    print("BP_PlayerStateBase:Initialize")
end

function BP_PlayerStateBase:Construct()
    print("BP_PlayerStateBase:Construct")
end

function BP_PlayerStateBase:Destruct()
    print("BP_PlayerStateBase:Destruct")
end

function BP_PlayerStateBase:ReceiveBeginPlay()
    self.bCanEverTick = true
    -- set bCanBeDamaged property in parent
    self.bCanBeDamaged = false
    print("BP_PlayerStateBase:ReceiveBeginPlay")
    self.Super:ReceiveBeginPlay()
end

function BP_PlayerStateBase:ReceiveEndPlay(reason)
    print("BP_PlayerStateBase:ReceiveEndPlay")
    self.Super:ReceiveEndPlay(reason)
end

return BP_PlayerStateBase