--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: Enums
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

---@class Enums 枚举命名空间
Enums = {}

---@field SceneType table 场景类型
Enums.SceneType = {
    LOBBY_MAIN = 1, -- 0x01
    LOBBY_SECOND = 2, -- 0x10
    PLUGIN_MAIN = 4, -- 0x100
    PLUGIN_SECOND = 8, -- 0x1000
    PLUGIN_TABLE = 16, -- 0x10000
    PLUGIN_MATCH = 32, -- 0x100000
    LOBBY_LOADING = 64, -- 0x1000000
    PLUGIN_LOADING = 128 -- 0x10000000
}

return Enums