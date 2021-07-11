--------------------------------------------------------------------
--- Copyright (C) 2021 tom
---
--- ModuleName: ViewController
--- Date: 2021/7/4
--- Author: tom
--- ChangeList:
--- Desc:
--------------------------------------------------------------------


---@class ViewControllerConfig 布局配置
---@generic T : ViewController
---@field ctor T 视图控制器类
---@field csd UISlotBinder csd文件名
---@field data table 视图控制器初始化数据
---@field params table 视图控制器初始化数据


--- 基础视图控制器
---@class ViewController
---@field protected dataModel any 数据模型
---@field protected view UUserWidget UI视图
---@field protected parentController ViewController 父视图控制器
---@field protected childControllers ViewController[] 子控制器数组
---@field protected isDestroyed boolean 控制器是否已销毁
---@field protected uiBinder UISlotBinder ui绑定器
---@field public _TAG string 类标签
local ViewController = Class('ViewController')

ViewController._TAG = 'ViewController'

--- 获取控制器名称
---@return string
function ViewController:getName()
    return self._TAG or 'unnamed'
end

--- 获取UI控件
---@return UUserWidget
function ViewController:getView()
    return self.view
end

---初始化函数
---@param binder UISlotBinder ui绑定器
---@param owner table ui文件事件绑定对象
function ViewController:init(binder, owner)
    self.uiBinder = binder
    self:onInit(binder, owner);
end

---供子类重载的初始化接口。加载UI文件
---@param binder UISlotBinder | UUserWidget ui绑定器
---@param owner table ui文件事件绑定对象
function ViewController:onInit(binder, owner)
    self:load(binder, owner)
end

---加载csd文件
---@param binder UISlotBinder | UUserWidget ui绑定器
---@param owner table ui文件事件绑定对象
function ViewController:load(binder, owner)
    if not binder then
        LOGE(self._TAG, '[viewController.load] binder 不能为空')
        return
    end

    if __DUDU_DEBUG__ then
        if not self.view then
            LOGE(self._TAG, 'self.view为空，子类构造函数是否没有调用self._super()')
        end
    end

    local ccsNode
    if (binder == cc.Node) then
        ccsNode = binder
        assert(not ccsNode.GetParent(), '视图控制器加载节点时，被加载节点的已存在父节点')
    else
        ccsNode = dd.Util.loadCCSFile(binder, owner or self, self)
        assert(ccsNode, 'ccs文件加载失败，根节点不存在:' .. JSON.stringify(binder))
    end

    self.view.rootNode = ccsNode
    self.view.animationManager = ccsNode.animationManager
    self:onSeekNode(owner)
    self:onLoad()
end

---UI文件解析后回调函数，子类必须Super此函数，用于绑定UI文件节点和类的属性
---@protected
---@param owner table
function ViewController:onSeekNode(owner)
    if self.uiBinder then
        self.uiBinder.bind(self.view, owner)
    end
end

---加载完成之后的接口
function ViewController:onLoad()
    if self.view then
        self.view.animationManager.setFrameEventCallFunc(function(event)
            self:_onFrameEvent(event)
        end)
    end

    self:registerAutoManageEventListeners()
end

--- UI被添加前回调
function ViewController:PreWidgetAddToViewport()
    --LOGD(self._TAG, "PreWidgetAddToViewport in base controller")
end

--- UI被添加后回调
function ViewController:PostWidgetAddToViewport()
    --LOGD(self._TAG, "PostWidgetAddToViewport in base controller")
end

--- UI被移除前回调
function ViewController:PreWidgetRemoveFromParent()
    --LOGD(self._TAG, "PreWidgetRemoveFromParent in base controller")
end

---UI被移除后回调
function ViewController:PostWidgetRemoveFromParent()
    --LOGD(self._TAG, "PostWidgetRemoveFromParent in base controller")
end

---控制器是否已被销毁
---@return boolean
function ViewController:isDestroyed()
    return self.isDestroyed
end

--/**
--* 销毁方法,递归调用子controller的销毁方法
--*/
function ViewController:destroy()
    if self.isDestroyed then
        LOGE(self._TAG, 'controller has been destroyed.')
        return
    end
    self.isDestroyed = true

    self.PreDestroy()

    -- 销毁子控制器
    self.childControllers.forEach(function(childController)
        childController.destroy()
    end)
    self.childControllers = {}

    if (self.view.rootNode) then
        -- 置空回调函数
        self.view.rootNode.setonEnterTransitionDidFinishCallback(undefined)
        self.view.rootNode.setOnEnterCallback(undefined)
        self.view.rootNode.setOnExitCallback(undefined)
        self.view.rootNode.removeFromParent()
    end

    self.dataModel = nil
    self.view = nil
    self.uiBinder = nil

    self.PostDestroy()
end

---控制器销毁时回调函数
function ViewController:PreDestroy()
    --LOGD(self._TAG, 'In PreDestroy --- ViewController')
    self.unRegisterAutoManageEventListeners()
end

---控制器完全销毁后回调函数
function ViewController:PostDestroy()
    --LOGD(self._TAG, 'In PostDestroy --- ViewController')
end

--- ------------------------ 子控制器管理 begin ------------------------

--/**
--* 获取父视图控制器
--* @return common.ViewController}
--*/
function ViewController:getParentController()
    return self.parentController
end

--/**
--* 根据标签查找控制器
--* @param string} controllerTag
--* @param boolean} [recursive] 是否递归子控制器查找
--* @returns common.ViewController}
--*/
function ViewController:findChildController(controllerTag, recursive)
    local childControllers = self.childControllers

    for i = 0, childControllers.length, 1 do
        local childController = childControllers[i]

        if (childController._TAG == controllerTag) then
            return childController
        end

        if (recursive) then
            local subVC = childController.findChildController(controllerTag, recursive)
            if (subVC) then
                return subVC
            end
        end

        return nil
    end
end

--/**
--* 添加子controller, 不允许在onDestroy和destroy内调用本方法!!!
--* @param common.ViewController} childController 子控制器
--* @param cc.Node} [attachedNode] 子控制器挂载节点, 挂载点为空时，默认挂载在rootNode下
--*/
function ViewController:addChildController(childController, attachedNode)
    --- 检查子控制器是否已存在
    local idx = self.childControllers.indexOf(childController)
    if (idx ~= -1) then
        dd.LOGE(self._TAG, 'childController被重复添加了!!!')
    else
        self.childControllers.push(childController)

        if (attachedNode) then
            attachedNode.addChild(childController.getRootNode())
        else
            self.getRootNode().addChild(childController.getRootNode())
        end

        childController.parentController = this
    end
end

--/**
--* 控制器从父控制器中移除
--* @param boolean} [isCleanUp=true] 是否清除节点。false时，仅将控制器从父控制器中删除，不销毁移除节点
--*/
function ViewController:removeFromParentController(isCleanUp)
    if self.parentController then
        self.parentController:removeChildController(this, isCleanUp)
    end
end

--/**
--* 移除子controller, 不允许在onDestroy和destroy内调用本方法!!!
--* @param common.ViewController} childController
--* @param boolean} [isCleanUp=true] 是否清除节点。false时，仅将控制器从父控制器中删除，不销毁移除节点
--*/
function ViewController:removeChildController(childController, isCleanUp)
    --- 检查子控制器是否存在
    local idx = self.childControllers.indexOf(childController)
    if (idx ~= -1) then
        --- 记录下TAG，方便查找是哪个控制器的问题
        local msg = ''
        if childController then
            msg = '_TAG: ' .. childController._TAG .. ' csd: ' .. childController._ccsFilename
        end
        LOGE(self._TAG, 'childController不在子控制器列表中!!! errMsg: ' .. msg)
        return
    end

    --- 数组移除 aChildController
    self.childControllers.splice(idx, 1)
    childController.parentController = nil

    if isCleanUp == nil then
        isCleanUp = true
    end

    if isCleanUp then
        childController.destroy()
    else
        childController.getRootNode().removeFromParent(false)
    end
end

---移除所有子controller
---@param isCleanUp boolean 是否清除节点.默认为true。false时，仅将控制器从父控制器中删除，不销毁移除节点
function ViewController:removeAllChildControllers(isCleanUp)
    if isCleanUp == nil then
        isCleanUp = true
    end

    local childControllers = self.childControllers

    for i = 0, childControllers.length, 1 do
        childControllers[i].parentController = nil

        if isCleanUp then
            childControllers[i].destroy()
        end
    end

    self.childControllers = {}
end

--- ------------------------ 子控制器管理 end ------------------------
---展示一个view的界面
function ViewController:show()
    self.onShow()
end

---供子类重载的显示接口
function ViewController:onShow()
    --- dd.LOGD(self._TAG, 'onShow ViewController')
end

--- =========================== 自动事件监听管理器 begin ===========================

--/**
--* 注册所有自动管理监听
--*/
function ViewController:registerAutoManageEventListeners()
    local eventMap = self.autoManageEventListeners()
    if eventMap then
        for key, value in ipairs(eventMap) do
            dd.NotificationCenter.listen(key, value, this)
        end
    end
end

--/**
--* 注销所有自动管理监听
--*/
function ViewController:unRegisterAutoManageEventListeners()
    local eventMap = self.autoManageEventListeners()
    if eventMap then
        for key, value in ipairs(eventMap) do
            dd.NotificationCenter.ignore(key, value, this)
        end
    end
end

--/**
--* 自动管理列表,重写这个方法来添加自动管理事件
--* @returns any}
--*/
---自动管理事件列表,重写这个方法来添加自动管理事件
function ViewController:autoManageEventListeners()
    return nil
end

--- =========================== 自动事件监听管理器 end ===========================

--- =========================== 动画管理器 begin ==============================
--/**
--* 跳到指定动画第一帧
--* @param string} animName 动画名称
--*/
function ViewController:gotoFirstFrameByAnimName(animName)
    local animMgr = self.view.animationManager
    local animInfo = animMgr.getAnimationInfo(animName)
    if (not animInfo) then
        return
    end
    self.view.animationManager.gotoFrameAndPause(animInfo.startIndex)
end

--/**
--* 跳到指定动画最后一帧
--* @param string} animName 动画名称
--*/
function ViewController:gotoLastFrameByAnimName(animName)
    local animMgr = self.view.animationManager
    local animInfo = animMgr.getAnimationInfo(animName)
    if not animInfo then
        return
    end
    self.view.animationManager.gotoFrameAndPause(animInfo.endIndex)
end

--/**
--* 跳到指定关键帧，并从指定帧开始播放
--* @param number} [startIndex=0] 开始关键帧
--* @param number} [endIndex] 结束关键帧
--* @param number} [currentFrameIndex=startIndex] 当前关键帧
--* @param boolean} [loop=false] 是否循环
--*/
function ViewController:gotoFrameAndPlay(startIndex, endIndex, currentFrameIndex, loop)
    self.view.animationManager.gotoFrameAndPlay(startIndex, endIndex, currentFrameIndex, loop)
end

--/**
--* 跳到指定关键帧，并且暂停播放
--* @param number} startIndex 开始关键帧
--*/
function ViewController:gotoFrameAndPause(startIndex)
    self.view.animationManager.gotoFrameAndPause(startIndex)
end

--/**
--* 播放一个动画
--* @param string} animName 动画名称
--* @param boolean} [isLoop=false] 是否循环
--*/
function ViewController:playAnim(animName, isLoop)
    self.view.animationManager.playAnim(animName, isLoop)
end

--/**
--* 暂停动画播放
--*/
function ViewController:pauseAnim()
    self.view.animationManager.pauseAnim()
end

--/**
--* 继续播放动画
--*/
function ViewController:resumeAnim()
    self.view.animationManager.resumeAnim()
end

--/**
--* 帧事件回调
--* @param ccs.EventFrame} event
--*/
function ViewController:_onFrameEvent(event)
    if (__DUDU_DEBUG__) then
        cc.log(cc.formatStr('FrameEvent event=%s, FrameIndex=%s', event.getEvent(), event.getFrameIndex()))
    end
end

return ViewController