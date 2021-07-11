--# UI框架说明
--框架基于MVC架构设计
--根据业务需求，划分多个场景。不同场景间通过SceneManager管理机制来切换。
--单个业务需求由Model、View、Controller组成
--Controller维护Model和View，并且可以通过事件或接口与其他Controller通信

--项目内MVC对应类
--M: XXXManager. 文件存放在Logic目录，每个模块对应一个Manager
--V: UMG and LuaScript. 文件存放在UI目录，每个UMG界面对应一个相同命名的lua脚本
--C: ViewController. 文件存放在UI目录，每个模块对应一个主控制器

--自动绑定节点说明：
--UI中通常需要获取指定的节点进行操作。在此，我们约定，此类节点统一以_下划线开头命名。并且禁止同名。同名节点将被后面的节点覆盖。
--框架将会自动把_节点赋值给owner.不需要手动绑定
--常规绑定方式: self.xxLbl = view.findChild('xxLbl')
--自动绑定可以跳过此过程，直接调用self.xxLbl

--UI事件说明：
--为了防止委托事件泄露，所有的UI委托事件必须通过封装好的接口绑定，禁止手动绑定事件。
--此类行为是禁止的： btn2.OnClicked:Add(function() end)。直接去绑定了点击事件
--应该使用self.AddClicked(btn2, function() end) 方式处理

--ViewController封装registerAutoManageEventListeners事件
--UI需要监听的事件，可以定义一个监听表，让视图控制器自动维护事件的生命周期，减少手动维护，可以有效避免事件忘记取消监听导致的异常
--常规方式:
--function XXXViewController.onLoad()
--    EventListener.add(self.onXXX, self)
--end
--function XXXViewController.PreDestroy()
--    EventListener.del(self.onXXX, self)
--end

--自动方式:
--function XXXViewController.autoManageEventListeners()
--    local eventMap = {} -- or append parent event? eventMap = DeepCopy(self.super:autoManageEventListeners()) or {}
--    eventMap[EventType.XXX] = self.onXXX
--    return eventMap
--end

--
--整体UI结构设计
--- Scene
--  - SceneController
--    - LayoutController
--      - TopViewController
--      - ContentViewController
--        - WindowViewController
--      - BottomViewController
--    - LedController
--    - AlarmController
--
--视图控制器划分
--- 基础视图控制器：所有视图控制器的基类，提供抽象的方法
--- 场景视图控制器：
--- 布局视图控制器：
--- 布局顶部视图控制器：
--- 布局内容视图控制器：
--- 布局底部视图控制器：
--- 窗口视图控制器：
--- Led视图控制器：
--- Alarm视图控制器：




