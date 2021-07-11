--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: LayoutController
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

---@class TopSubViewConfig 顶部视图配置
---@field key string
---@field title string

---@class TopControllerConfig 顶部视图控制器配置
---@generic T : SceneController
---@field isShopStyle boolean
---@field fixSubView boolean
---@field subViews TopSubViewConfig[]

---@class LayoutControllerConfig 布局配置
---@generic T : LayoutController
---@field layoutClass T
---@field csd UISlotBinder
---@field data table
---@field contentConfig ViewControllerConfig
---@field topConfig TopControllerConfig


---@class LayoutController 布局控制器
local LayoutController = Class('LayoutController', AdaptationController)

function LayoutController:initialize(data)
    self.super:initialize()
    this._data = data
end

function LayoutController:onLoad()
    this._super()

    dd.NotificationCenter.listen(common.EventType.EVT_TOP_ON_BTN_BACK_CLICKED, this._onBtnBack, this)
    dd.NotificationCenter.listen(common.EventType.EVT_ON_SCENE_BACK, this._onSceneBack, this)
end

function LayoutController:PreDestroy()
    dd.NotificationCenter.ignore(common.EventType.EVT_TOP_ON_BTN_BACK_CLICKED, this._onBtnBack, this)
    dd.NotificationCenter.ignore(common.EventType.EVT_ON_SCENE_BACK, this._onSceneBack, this)
    self.super:PreDestroy()
end

---获取容器尺寸
---@return FVector2D
function LayoutController:getContainerSize()
    return this._contentView.getContentSize()
end

---添加主体内容视图控制器
---@param contentController ViewController
function LayoutController:addContentController(contentController)
    this.addChildController(contentController, this._contentView)
end

---添加子controller, 不允许在onDestroy和destroy内调用本方法!!!
---@param childController ViewController 子控制器
---@param attachedNode UUserWidget 子控制器挂载节点, 挂载点为空时，默认挂载在rootNode下
function LayoutController:addChildController(childController, attachedNode)
    -- 默认挂载节点为this._contentView
    this._super(childController, attachedNode or this._contentView)
end

---场景被压入场景堆栈中
function LayoutController:onPushToSceneStack()
end

---重新从场景栈中弹出回到场景最上层
function LayoutController:onBackToSceneTop()
end

---背景被点击,放置点穿
---@private
function LayoutController:_onBgBtnClick()
    LOGW(this._TAG, '_onBgBtnClick not implemented')
end

---场景返回事件监听
function LayoutController:_onSceneBack()
    if (this._data) then
        if (this._data.autoClose) then
            dd.NotificationCenter.trigger(common.EventType.EVT_CANCEL_SCENE_BACK)
            this.layerClose()
        else
            LOGW(this._TAG, '_onSceneBack -> no _data')
        end
    else
        LOGW(this._TAG, '_onSceneBack -> no _data.autoClose')
    end
end

---返回按钮回调
function LayoutController:_onBtnBack()
    if (this._data) then
        if (this._data.autoClose) then
            this.layerClose()
        else
            LOGW(this._TAG, '_onBtnBack -> no _data')
        end
    else
        LOGW(this._TAG, '_onBtnBack -> no _data.autoClose')
    end
end

function LayoutController:layerClose()
    if not this._closed then
        this._closed = true
        this.removeFromParentController()
    end
end

return LayoutController