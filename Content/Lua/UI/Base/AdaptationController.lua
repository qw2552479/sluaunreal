--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: AdaptationController
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc:
--- 一般不需要适配的界面，直接继承common.ViewController即可
--- 需要自动适配的界面继承自该类，可以自动适配界面
--- 需要自定义适配方案的界面，重写_onScreenAdaptation函数，实现自定义的适配方案
--------------------------------------------------------------------


---@class AdaptationController : ViewController 自适应视图控制器
---@field super ViewController 父类指针
local AdaptationController = Class('AdaptationController', ViewController)

function AdaptationController:onLoad()
    self.super:onLoad()
    self:_onScreenAdaptation()
    dd.NotificationCenter.listen(dd.EventType.WINDOW_RESIZE, this._onScreenAdaptation, this)
end

function AdaptationController:PreDestroy()
    dd.NotificationCenter.ignore(dd.EventType.WINDOW_RESIZE, this._onScreenAdaptation, this)
    self.super:PreDestroy()
end

---屏幕适配回调函数
---@protected
function AdaptationController:_onScreenAdaptation()

end

return AdaptationController