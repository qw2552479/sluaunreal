--------------------------------------------------------------------
--- Copyright (C) 2021
---
--- ModuleName: WindowController
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc:
--------------------------------------------------------------------


---@class WindowConfig 窗口配置
---@field swallowTouches boolean
---@field maskVisible boolean
---@field clickBtnCloseWindow 'enable'|'disable'|'custom'
---@field clickMaskCloseWindow 'enable'|'disable'|'custom'
---@field clickPanelCloseWindow 'enable'|'disable'|'custom'
---@field backKeyCloseWindow 'enable'|'disable'|'custom'
---@field aniShow 'delayScaleOut'|'none'|'scaleOut'|'scaleIn'|string
---@field aniHide 'delayScaleOut'|'none'|'scaleOut'|'scaleIn'|string
---@field blurScreenBg boolean
---@field windowKey string
---@field duplicate string
---@field isFullScreen boolean

local _DefaultConfig = {
    maskVisible = true, -- 默认显示背板
    swallowTouches = true,
    clickBtnCloseWindow = 'enable', -- 默认有关闭按钮
    clickMaskCloseWindow = 'enable', -- 默认点击蒙板关闭窗口
    clickPanelCloseWindow = 'disable', --  默认点击panel无效
    backKeyCloseWindow = 'disable', --  默认禁止返回键
    aniShow = 'scaleOut', --  默认的弹出方式
    aniHide = 'scaleIn', --  默认的隐藏方式
    duplicate = 'allow', --
    blurScreenBg = true, --
    isFullScreen = false -- 是否是全屏弹窗
}

---@class WindowController : AdaptationController 窗口控制器
local WindowController = Class('WindowController', AdaptationController)

function WindowController:initialize()
    ---@field private touchPriority number 点击优先级
    this._touchPriority = 0
    ---@field private windowConfig WindowConfig 窗口配置
    this._windowConfig = {}
    ---@field private windowParam WindowConfig 窗口参数
    this._windowParam = {}
    ---@field private _windowRootNode UUserWidget 弹出窗口根节点
    this._windowRootNode = null
    ---@field private _closing boolean 正在关闭
    this._closing = false

    -- 设置默认配置
    this.setWindowConfig(_DefaultConfig)
end

function WindowController:onSeekNode()
    this._super()

    local rootNode = this.getRootNode()

    this._closeBtn = ccui.helper.seekWidgetByName(rootNode, '_closeBtn')
    this._windowRootNode = ccui.helper.seekWidgetByName(rootNode, '_windowRootNode')

    if not this._windowRootNode then
        Error('弹窗界面必须存在_windowRootNode节点: _ccsFilename=' + this._ccsFilename)
    end
end

function WindowController:onLoad()
    this._super()
    this._initByWindowConfig()
end

function WindowController:PreDestroy()
    this._closing = false
    this._touchListener = null
    self.super:PreDestroy()
end

---屏幕适配回调函数
---protected
function WindowController:_onScreenAdaptation()
    this._super()
end

function WindowController:onTouchBegan(touch, event)
    return true
end

function WindowController:onTouchEnded(touch, event)
    local pos = touch.getLocation()

    if (this._windowRootNode == UUserWidget) then
        if (this._windowRootNode.hitTest(pos)) then
            this._onPanelClick()
            return
        end

    else
        local size = this._windowRootNode.getContentSize()
        local rect = cc.rect(0, 0, size.width, size.height)
        local posInRect = this._windowRootNode.convertToNodeSpace(pos)
        if (cc.rectContainsPoint(rect, posInRect)) then
            this._onPanelClick()
            return
        end
    end

    this._onMaskClick()
end

--/**
--* 设置弹窗参数
--* @param {any} param
--* @returns {boolean}
--    * @private
--    */
---设置弹窗参数
function WindowController:_setWindowParam(param)
    this._windowParam = param or {}
    if (this._windowParam.windowConfig) then
        this.setWindowConfig(this._windowParam.windowConfig)
    end
    return true
end

--/**
--* 获取弹窗参数，子类获取事件传递的参数
--* @returns {{}|*}
--*/
---获取弹窗参数，子类获取事件传递的参数
---@return table
function WindowController:getWindowParam()
    return this._windowParam
end

---根据windowConfig初始化弹窗基类部分功能
---@private
function WindowController:_initByWindowConfig()
    local windowConfig = this.getWindowConfig()

    if this._closeBtn then
        -- 默认显示关闭按钮
        this._closeBtn.setVisible(true)

        if (windowConfig and windowConfig.clickBtnCloseWindow == 'disable') then
            this._closeBtn.setVisible(false)
        end
    end

    if (windowConfig.blurScreenBg and cc.sys.isNative) then
        this._blurScreenBg = common.DisplayHelper.getScreenBlurLayer(1)
        this.getRootNode().addChild(this._blurScreenBg, -2)
    end

    -- 默认显示背板
    if (windowConfig.maskVisible) then
        -- add mask color layer
        local wndCounts = common.WindowManager.getWindowCount()
        -- 如果已经有一层蒙板了，不必要再加一层蒙板
        if (wndCounts == 0) then
            local maskColor = windowConfig['maskColor'] or { 0, 0, 0, 255 }
            local layer = new
            cc.LayerColor(cc.color(maskColor[0], maskColor[1], maskColor[2], maskColor[3]))
            this.getRootNode().addChild(layer, -1)
            layer.setOpacity(_MASK_OPACITY)
            layer.setScale(2)-- 某些特殊情况,边缘有缝隙,这里做个缩放,防御一下
            this._maskLayer = layer
        end
    end

    if (windowConfig.swallowTouches) then
        local self = this
        this._touchListener = cc.eventManager.addListener({
            event = cc.EventListener.TOUCH_ONE_BY_ONE,
            swallowTouches = true,
            onTouchBegan = self.onTouchBegan.bind(self),
            onTouchEnded = self.onTouchEnded.bind(self)
        }, this._windowRootNode)
    end
end

---获取点击优先级,为setTouchPriority -1 即 蒙版上一级的优先级
---@return number
function WindowController:getBaseTouchPriority()
    return this._touchPriority - 1
end

---物理返回调响应,基类入口,子类不要重写!
---@private
function WindowController:_onBackKeyClicked()
    local backKeyCloseWindow = this.getWindowConfig().backKeyCloseWindow
    if backKeyCloseWindow == 'enable' then
        this.closeWindow()
    elseif
    backKeyCloseWindow == 'disable' then
    elseif
    backKeyCloseWindow == 'custom' then
        this.onBackKeyClicked()
    else
        LOGW(this._TAG, '_onBackKeyClicked')
    end
end

---物理返回键,custom模式下,子类重写用
---@protected
function WindowController:onBackKeyClicked()
end

---关闭按钮回调响应,基类入口,子类不要重写!
---@private
function WindowController:_onCloseBtnClick()
    local clickBtnCloseWindow = this.getWindowConfig().clickBtnCloseWindow
    if clickBtnCloseWindow == 'enable' then
        this.closeWindow()
    elseif
    clickBtnCloseWindow == 'disable' then
    elseif
    clickBtnCloseWindow == 'custom' then
        this.onCloseBtnClick()
    else
        LOGW(this._TAG, '_onCloseBtnClick')
    end
end

---关闭按钮回调响应,custom模式下,子类重写用
---@protected
function WindowController:onCloseBtnClick()

end

---点击面板回调响应,基类入口,子类不要重写!
---@private
function WindowController:_onPanelClick()
    local clickPanelCloseWindow = this.getWindowConfig().clickPanelCloseWindow;

    if clickPanelCloseWindow == 'enable' then
        this.closeWindow()
    elseif
    clickPanelCloseWindow == 'disable' then
    elseif
    clickPanelCloseWindow == 'custom' then
        this.onPanelClick()
    else
        LOGW(this._TAG, '_onPanelClick')
    end
end

---点击面板回调响应,custom模式下,子类重写用
---@protected
function WindowController:onPanelClick()

end

---点击蒙版回调响应,基类入口,子类不要重写!
---@private
function WindowController:_onMaskClick()
    local clickMaskCloseWindow = this.getWindowConfig().clickMaskCloseWindow;

    if clickMaskCloseWindow == 'enable' then
        this.closeWindow()
    elseif
    clickMaskCloseWindow == 'disable' then
    elseif
    clickMaskCloseWindow == 'custom' then
        this.onMaskClick()
    else
        LOGW(this._TAG, '_onMaskClick')
    end
end

---点击蒙版回调响应,custom模式下,子类重写用
---@protected
function WindowController:onMaskClick()
    return true
end

---显示弹窗调用接口,通过addChildController添加到当前场景主controller上
function WindowController:showWindow()
    local curController = common.SceneManager.getCurrentController()
    if (curController) then
        curController.addWindowView(this)
    else
        LOGE(this._TAG, 'curController is null, need check....')
        return
    end

    local callback = function()
        self:onShowAnimFinish()
    end

    this._playAniByConfig(this.getWindowConfig().aniShow, callback)
end

---显示动画完成的回调
function WindowController:onShowAnimFinish()

end

---主动关闭窗口
function WindowController:closeWindow()
    if this._closing then
        return
    end

    this._closing = true

    local windowObj = this
    local closeFunction = function()
        windowObj._closing = false
        local param = windowObj.getWindowParam()
        local config = windowObj.getWindowConfig()

        windowObj.onWindowClosed()

        windowObj.removeFromParentController()

        -- 窗口关闭
        dd.NotificationCenter.trigger(common.EventType.WND_CLOSED, param, config)
    end

    -- windowManager移除
    if common.WindowManager then
        common.WindowManager.removeWindow(this)
    end

    this.onWindowClosing()

    this._playAniByConfig(this.getWindowConfig().aniHide, closeFunction)
end

---窗口即将关闭
function WindowController:onWindowClosing()
    dd.NotificationCenter.trigger(common.EventType.WND_WILL_CLOSED, this.getWindowParam(), this.getWindowConfig())
end

---窗口关闭
function WindowController:onWindowClosed()
end

---播放显示和隐藏动画,播放结束后执行回调
---@param aniConfig table 动画配置
---@param callBack table 播放结束回调函数
function WindowController:_playAniByConfig(aniConfig, callBack)
    if this.isDestroyed() then
        callBack()
        return
    end

    local baseScale = 1
    if aniConfig == 'scaleOut' then
        local scaleAct = cc.scaleTo(10 / 60, 1).easing(cc.easeBackOut())
        local cbAct = cc.callFunc(function()
            callBack()
        end)
        -- 缩放弹出
        this._windowRootNode.setScale(0)
        this._windowRootNode.setOpacity(0)
        this._windowRootNode.stopActionByTag(_WND_ROOT_NODE_SHOW_ACT_TAG)
        this._windowRootNode.runAction(cc.spawn(cc.sequence(scaleAct, cbAct), cc.fadeIn(10 / 60)))
            .setTag(_WND_ROOT_NODE_SHOW_ACT_TAG)
        if (this._maskLayer) then
            this._maskLayer.setOpacity(0)
            this._maskLayer.stopActionByTag(_MASK_SHOW_ACT_TAG)
            this._maskLayer.runAction(cc.fadeTo(15 / 60, _MASK_OPACITY)).setTag(_MASK_SHOW_ACT_TAG)
        end
    elseif aniConfig == 'scaleIn' then
        local seqAct = cc.sequence(cc.scaleTo(8 / 60, 0), cc.callFunc(function()
            callBack()
        end))
        -- 缩放收起
        this._windowRootNode.setScale(baseScale)
        this._windowRootNode.stopActionByTag(_WND_ROOT_NODE_HIDE_ACT_TAG)
        this._windowRootNode.runAction(cc.spawn(seqAct, cc.fadeTo(8 / 60, 0)))
            .setTag(_WND_ROOT_NODE_HIDE_ACT_TAG)
        if (this._maskLayer) then
            this._maskLayer.setOpacity(_MASK_OPACITY)
            this._maskLayer.stopActionByTag(_MASK_HIDE_ACT_TAG)
            this._maskLayer.runAction(cc.fadeTo(8 / 60, 0).easing(cc.easeQuadraticActionOut()))
                .setTag(_MASK_HIDE_ACT_TAG)
        end
    elseif aniConfig == 'delayScaleOut' then
        -- 延时缩放弹出
        this._windowRootNode.setScale(0)
        this._windowRootNode.runAction(cc.sequence(cc.delayTime(0.2), -- 延迟0.2秒再显示
                cc.scaleTo(15 / 60, baseScale).easing(cc.easeBackOut()), cc.callFunc(function()
                    callBack()
                end)
        ))
    elseif aniConfig == 'none' then
        this._windowRootNode.setScale(baseScale)
        callBack()
    else
        if (aniConfig.indexOf('win-custom') ~= -1) then
            this.playAnim(aniConfig.split(':')[1])
            this.view.animationManager.setLastFrameCallFunc(function()

                if callBack then
                    callBack()
                end
            end)
        else
            LOGE(this._TAG, '未定义的动画!!!')
        end
    end
end

---设置窗口配置
---@param windowConfig WindowConfig 窗口配置
function WindowController:setWindowConfig(windowConfig)
    this._windowConfig = windowConfig
end

---获取窗口配置
---@return WindowConfig
function WindowController:getWindowConfig()
    return this._windowConfig or {}
end

---设置是否显示关闭按钮
---@param enable "enable|disable|custom" 是否启用关闭按钮
function WindowController:setClickBtnCloseWindow(enable)
    this._windowConfig.clickBtnCloseWindow = enable
end

---设置是否点击蒙板关闭弹窗
---@param enable "enable|disable|custom" 点击蒙板是否关闭弹窗
function WindowController:setClickMaskCloseWindow(enable)
    this._windowConfig.clickMaskCloseWindow = enable
end

---是否有蒙板
---@param enable "enable|disable|custom" 是否有蒙板
function WindowController:setMaskVisible(enable)
    this._windowConfig.maskVisible = enable
end

return WindowController