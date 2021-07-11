--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: BP_CharacterBase
--- Date: 2021/7/11
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

local BP_CharacterBase = {}

function BP_CharacterBase:Initialize()
    print("BP_CharacterBase:Initialize")
end

function BP_CharacterBase:Construct()
    print("BP_CharacterBase:Construct")
end

function BP_CharacterBase:Destruct()
    print("BP_CharacterBase:Destruct")
end

function BP_CharacterBase:ReceiveBeginPlay()
    self.bCanEverTick = true
    -- set bCanBeDamaged property in parent
    self.bCanBeDamaged = false
    print("BP_CharacterBase:ReceiveBeginPlay")
    self.Super:ReceiveBeginPlay()
end

function BP_CharacterBase:ReceiveEndPlay(reason)
    print("BP_CharacterBase:ReceiveEndPlay")
    self.Super:ReceiveEndPlay(reason)
end

return BP_CharacterBase