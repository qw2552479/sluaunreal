--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: Badge
--- Date: 2021/7/6
--- Author: tom admin
--- ChangeList:
--- Desc: 按钮小红点
--------------------------------------------------------------------

Badge = {
    _TAG = 'Badge',
    stateMap = {},
}

function Badge.init()

end

function Badge.destroy()

end

---监听节点
---@param type string 小红点事件类型
---@param node UUserWidget 显示的节点
function Badge.watchNode(type, node)

end

---取消监听节点
---@param type string 小红点事件类型
---@param node UUserWidget 显示的节点
function Badge.unwatchNode(type, node)

end

---注册状态
---@private
---@param type string
---@param show boolean
---@param count number
---@param node UUserWidget
function Badge.registerState(type, show, count, node)

end

---角标状态改变事件回调函数
---@private
---@param type string 小红点事件类型
---@param show boolean 是否显示
---@param count number 数量
function Badge.onBadgeChanged(type, show, count)

end

return Badge