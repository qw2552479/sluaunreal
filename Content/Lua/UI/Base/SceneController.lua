--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: SceneController
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc:
--- 场景view，实现分层 windowView > ledView
--- 作为一级场景的窗口
--- 每个场景控制器都存在一个场景控制器栈，允许多个场景控制器同时存在
--- 当存在多个场景控制器时，返回按钮会依次弹出栈内的场景控制器
--------------------------------------------------------------------

---@class SceneControllerConfig 场景控制器参数配置
---@generic T : SceneController
---@field sceneType number
---@field gameId number
---@field layoutConfig LayoutControllerConfig
---@field ledUICsd string
---@field customSceneControllerClass T 自定义场景控制器类
---@field customSceneControllerUIBinder UISlotBinder 自定义场景csd绑定器
---@field preferOrientation number
---@field forceOrientation boolean


---@class SceneController : AdaptationController 场景视图控制器
local SceneController = Class('SceneController', AdaptationController)

---构造函数
---@param sceneConfig SceneControllerConfig 场景配置
---@param isSubScene boolean 是否时子场景控制器
function SceneController:initialize(sceneConfig, isSubScene)
    this._super()
    this._sceneType = 0
    this._keyEventListener = nil
    ---@field protected _sceneStack SceneController[] 场景堆栈
    this._sceneStack = {}
    ---@field protected _sceneStack boolean 子场景UI
    this._isSubScene = isSubScene

    ---@field protected _sceneBackEnable boolean 场景返回有效性标志位,每次返回前置为true,如果事件环节结束还是 true 则执行
    this._sceneBackEnable = true
    ---@field protected _layoutController LayoutController 布局控制器
    this._layoutController = nil
    ---@field protected _forceOrientation number 是否优先使用横屏模式，false为竖屏模式。子类可以修改
    this._preferOrientation = false
    ---@field protected _forceOrientation boolean 是否强制指定横竖屏模式。子类可以修改
    this._forceOrientation = false
end

function SceneController:onLoad()
    this._super()
    this._addBackKeyListener()

    dd.NotificationCenter.listen(common.EventType.EVT_TOP_ON_BTN_BACK_CLICKED, this.onBtnBackClicked, this)
end

function SceneController:onDestroy()
    this._showExitFullScreenTip = false
    dd.Timer.cancelTimer(this, this._onRemoveOrientationWarn)

    this._keyEventListener = null
    this._layoutController = null
    dd.NotificationCenter.ignore(common.EventType.EVT_TOP_ON_BTN_BACK_CLICKED, this.onBtnBackClicked, this)
    this._super()
end

---屏幕适配回调函数
---@protected
function SceneController:_onScreenAdaptation()
    if (this._isSubScene) then
        common.AdaptationController.fixNodeBySafeAreaRect(this.getRootNode(), false)
    else
        common.AdaptationController.fixNodeBySafeAreaRect(this.getRootNode(), true)
    end

    -- 窗口层自适应，避免在窄屏幕上，窗口出界
    common.AdaptationController.fixNodeWidthFixedWidth(this._windowPlaceholder)
end

---是否允许执行进入游戏的流程
---@return boolean
function SceneController:isAllowEnterGame()
    return true
end

---获取场景类型
---@return number
function SceneController:getSceneType()
    local len = this._sceneStack.length
    if (len > 0) then
        return this._sceneStack[len - 1].getSceneType()
    end
    return this._sceneType
end

---设置控制器所在场景类型
---@param type number 场景类型
function SceneController:setSceneType(type)
    this._sceneType = type or 0
end

function SceneController:setVisible(visible)
    this._layoutPlaceholder.setVisible(visible)
    this._ledPlaceholder.setVisible(visible)
    this._windowPlaceholder.setVisible(visible)
end

---查看最上层的场景控制器
---@return SceneController
function SceneController:peekSceneController()
    local scenes = this._sceneStack
    if scenes and scenes.length > 0 then
        return scenes[scenes.length - 1]
    else
        return nil
    end
end

---将新的场景控制器压入栈中
---@param sceneController SceneController
---@param dontHide boolean
function SceneController:pushSceneController(sceneController, dontHide)
    local scenes = this._sceneStack
    -- 隐藏所有现有 layer
    for i = 0, scenes.length, 1 do
        if (scenes[i].getRootNode()) then
            scenes[i].getRootNode().setVisible(false)
        end
    end

    if not dontHide then
        this.setVisible(false)
    end

    if scenes.length == 0 then
        this.getLayoutController().onPushToSceneStack()
    end

    scenes.push(sceneController)

    this.addChildController(sceneController)
end

---弹出最后一个场景
---@return SceneController
function SceneController:popSceneController()
    local sceneStack = this._sceneStack
    -- 栈为空，触发事件
    if (sceneStack.length == 0) then
        -- 最后一个场景层,弹退出提示
        cc.director.getRunningScene().scheduleOnce(function()
            dd.NotificationCenter.trigger(common.EventType.EVT_COMMAND_WINDOW_EXIT)
        end, 0, this._TAG + 'popSceneController')

        this.setVisible(true)
        return nil
    end

    -- 弹出的视图控制器
    local popController
    -- 将显示的视图控制器
    local showController

    if (sceneStack.length == 1) then
        popController = sceneStack[0]
        showController = this
    else
        popController = sceneStack[sceneStack.length - 1]
        showController = sceneStack[sceneStack.length - 2]
    end

    -- 移除弹出的视图控制器
    this.removeChildController(popController)
    if (showController.getRootNode()) then
        showController.getRootNode().setVisible(true)
        local layoutController = showController.getLayoutController()
        layoutController.onBackToSceneTop()
    end
    if (sceneStack.length == 0) then
        this.setVisible(true)
    end

    return popController
end

---获取场景控制器上最顶层的特效节点（比窗口的层级还要高）
---@return UUserWidget
function SceneController:getSceneTopEffectNode()
    return this._sceneTopEffectNode
end

---返回layoutController.注意：通过push的场景这个返回的controller还是上一个的layoutController
---@return LayoutController
function SceneController:getLayoutController()
    return this._layoutController
end

---添加布局视图
---@param layoutView LayoutController
function SceneController:addLayoutView(layoutView)
    this._layoutController = layoutView
    this.addChildController(layoutView, this._layoutPlaceholder)
end

---led 就是横着播的通知消息,下翻式也可以做在这一层
---@param ledView ViewController
function SceneController:addLedView(ledView)
    this.addChildController(ledView, this._ledPlaceholder)
end

---通知视图
---@param alarmView ViewController
function SceneController:addAlarmView(alarmView)
    this.addChildController(alarmView, this._alarmView)
end

---增加窗口
---@param windowView WindowController
function SceneController:addWindowView(windowView)
    -- todo 如果场景是push之后，这个地方仍是最下面的那个LayoutController层
    local len = this._sceneStack.length
    if (len > 0) then
        -- 如果有场景栈，则加在最上层的SceneController上
        this._sceneStack[len - 1].addWindowView(windowView)
        return
    end
    if (windowView.getWindowConfig().isFullScreen) then
        this.addChildController(windowView, this._fullScreenWindowPlaceholder)
    else
        this.addChildController(windowView, this._windowPlaceholder)
    end
end

---场景返回操作
function SceneController:sceneBack()
    if (not common.WindowManager._onBackKeyClicked()) then
        -- 设置返回有效标志位
        this._sceneBackEnable = true
        -- 通知即将返回,如果其他 view 需要取消返回,需要触发HALL_CANCEL_SCENE_BACK事件
        -- 利用事件系统同步执行的特殊情况,如果改为异步,则这里需要改
        -- dd.NotificationCenter.trigger(common.EventType.EVT_ON_SCENE_BACK)
        -- 判断是否有场景取消返回
        if (this._sceneBackEnable) then
            local that = this
            -- 延迟一帧执行,否则要出事
            cc.director.getRunningScene().scheduleOnce(function()
                that.onKeyBackAfterWindowClicked()
            end, 0)
        else
            LOGW(this._TAG, '返回场景操作被取消了!')
        end
    end
end

function SceneController:onCancelSceneBack()
    this._sceneBackEnable = false
end

---物理返回键
function SceneController:onKeyBackClicked()
    this.sceneBack()
end

---top 返回按钮事件
function SceneController:onBtnBackClicked()
    this.sceneBack()
end

---添加物理返回键回调
---@private
function SceneController:_addBackKeyListener()
    local that = this
    this._keyEventListener = cc.eventManager.addListener({
        event = cc.EventListener.KEYBOARD,
        onKeyReleased = function(keycode, event)
            if (keycode == cc.KEY.back) then
                that.onKeyBackClicked()
            end
        end }, this.getRootNode())
end

function SceneController:onKeyBackAfterWindowClicked()
    this.popSceneController()
end

---移除子controller, 不允许在onDestroy和destroy内调用本方法!!!
---@param childController ViewController
function SceneController:removeChildController(childController)
    if childController.isSubclassOf(SceneController) then
        local sceneController = childController
        local idx = this._sceneStack.indexOf(sceneController)
        if (idx ~= -1) then
            this._sceneStack.splice(idx, 1)
        end
    end
    return this._super(childController)
end

function SceneController:getSceneStack()
    return this._sceneStack
end

---创建场景视图控制器
---@param params SceneControllerConfig
---@param isSubScene boolean
---@return SceneController
function SceneController.create(params, isSubScene)
    local sceneController
    if (params.customSceneControllerClass and params.customSceneControllerUIBinder) then
        sceneController = params.customSceneControllerClass:new(params, not not isSubScene)
        sceneController.init(params.customSceneControllerUIBinder)
    else
        sceneController = SceneController:new(params, not not isSubScene)
        sceneController.init(common.CSD.COMMON_SCENE_JSON)
    end

    sceneController.setSceneType(params.sceneType)

    -- 创建led
    if (params.ledClass) then
        local ledController = params.ledClass:new(params.ledUICsd)
        ledController.setGameId(params.gameId)
        sceneController.addLedView(ledController)
    end

    -- 创建alarm
    if (params.alarmClass) then
        local alarmController = params.alarmClass:new()
        sceneController.addAlarmView(alarmController)
    end

    local layoutConfig = params.layoutConfig or {}
    local layoutClass = layoutConfig.layoutClass or common.LayoutController

    -- 创建layout
    local layoutController = layoutClass:new(layoutConfig.data)
    if (layoutConfig.csd) then
        layoutController.init(layoutConfig.csd, layoutController)
    else
        layoutController.init(common.CSD.COMMON_LAYOUT_JSON)
    end

    -- 添加内容 view
    local contentConfig = layoutConfig.contentConfig
    if (contentConfig) then
        local contentController = contentConfig.ctor:new(contentConfig.params)
        if (contentConfig.csd) then
            contentController.init(contentConfig.csd)
        end
        layoutController.addContentController(contentController)
    end
    sceneController.addLayoutView(layoutController)

    return sceneController
end

return SceneController
