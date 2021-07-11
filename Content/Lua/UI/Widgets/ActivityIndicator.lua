--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: ActivityIndicator
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc: 等待时的菊花loading。同一时刻只会显示一个。
--------------------------------------------------------------------

local ActivityIndicator = Class('ActivityIndicator')

---显示活动指示器
---@param delay number 延迟销毁时间
---@param callback fun(...) 回调函数
---@param thisObj table 回调函数调用者
---@vararg any 参数
function ActivityIndicator.show(delay, callback, thisObj, ...)

end

return ActivityIndicator