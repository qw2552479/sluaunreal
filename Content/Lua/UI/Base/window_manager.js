/**
 * @namespace
 */
var common;
(function(common) {
    /**
     * 弹出窗口栈
     * @type {common.WindowController[]}
     * @private
     */
    var _windowStack = [];
    var _touchPriorityIndex = -10000;

    /**
     * 全局窗口管理器
     * @class
     * @static
     * @DDGroup UI管理器,1
     */
    common.WindowManager = {
        _TAG: 'common.WindowManager',

        /**
         * 添加窗口到管理栈中，返回是否添加成功，成功才弹出
         * @param {common.WindowController} windowController
         * @return {boolean}
         */
        addWindow: function(windowController) {
            var windowConfig = windowController.getWindowConfig();
            // 对重复窗口做判断
            if (windowConfig.windowKey && windowConfig.duplicate) {
                switch (windowConfig.duplicate) {
                    case 'replace':
                        // 如果有重复,替换掉原有窗口
                        common.WindowManager.removeWindowByKey(windowConfig.windowKey);
                        break;
                    case 'ignore':
                        // 如果有重复,无视新窗口
                        var oldWindow = common.WindowManager.findFirstWindowByKey(windowConfig.windowKey);
                        if (oldWindow) {
                            var wndParam = windowController.getWindowParam();
                            // 更新老窗口数据
                            oldWindow._setWindowParam(wndParam);
                            if (oldWindow.updateData) {
                                oldWindow.updateData();
                            }
                            windowController.destroy();
                            return false;
                        }
                        break;
                    case 'allow':
                        // 如果有重复,都正常弹出
                        // 啥也不做
                        break;
                }
            }

            // 设置新弹窗优先级
            // windowController.setTouchPriority(_touchPriorityIndex);

            // 添加节点到管理栈
            _windowStack.push(windowController);

            return true;
        },

        /**
         * 移除窗口
         * @param {common.WindowController} window
         */
        removeWindow: function(window) {
            // 只的移除,不做其他操作
            for (var i = 0; i < _windowStack.length; i++) {
                if (_windowStack[i] === window) {
                    _windowStack.splice(i, 1);
                    break;
                }
            }
        },

        getWindowCount: function() {
            return _windowStack ? _windowStack.length : 0;
        },

        /**
         * 获取当前弹窗点击优先级,并自增
         * @returns {number|*}
         */
        nextTouchPriority: function() {
            // 自增优先级
            common.WindowManager._incTouchPriorityIndex();

            return _touchPriorityIndex;
        },

        /**
         * 清空弹窗列表,用于场景切换时调用
         */
        clearWindowStack: function() {
            _windowStack = [];
        },

        /**
         * 销毁除了ignoreList中的window之外的所有弹窗
         * @param {string[]} [ignoreWindowKeys]
         */
        removeAllWindow: function(ignoreWindowKeys) {
            ignoreWindowKeys = ignoreWindowKeys || [];
            for (var i = 0; i < _windowStack.length; i++) {
                var windowObj = _windowStack[i];

                var ignore = false;
                for (var j = 0; j < ignoreWindowKeys.length; j++) {
                    if (windowObj.getWindowConfig().windowKey === ignoreWindowKeys[j]) {
                        ignore = true;
                    }
                }
                // 如果在ignoreList中,则不销毁
                if (ignore) {
                    continue;
                }

                windowObj.removeFromParentController();
            }
            _windowStack = [];
        },

        /**
         * 根据windowKey找到第一个弹窗
         * @param {string} windowKey
         * @returns {common.WindowController}
         */
        findFirstWindowByKey: function(windowKey) {
            for (var i = 0; i < _windowStack.length; i++) {
                if (_windowStack[i].getWindowConfig().windowKey == windowKey) {
                    return _windowStack[i];
                }
            }
            return null;
        },

        /**
         * 根据windowKey关闭窗口
         * @param {string} windowKey
         */
        removeWindowByKey: function(windowKey) {
            var i; var stackLen; var removedWindow;
            while (true) {
                removedWindow = false;
                stackLen = _windowStack.length;
                for (i = 0; i < _windowStack.length; i++) {
                    if (_windowStack[i].getWindowConfig().windowKey == windowKey) {
                        _windowStack[i].windowClose();
                        removedWindow = (stackLen != _windowStack.length);
                        break;
                    }
                }
                if (!removedWindow) {
                    break;
                }
            }
        },

        /**
         * 重置_touchPriorityIndex
         */
        resetTouchPriorityIndex: function() {
            _touchPriorityIndex = -10000;
        },

        /**
         * 物理返回键回到入口,传给弹窗堆栈顶得窗口处理
         * @returns {boolean}
         * @private
         */
        _onBackKeyClicked: function() {
            // 获取栈顶弹窗,调用其onBackKeyClicked
            if (_windowStack.length > 0) {
                _windowStack[_windowStack.length - 1]._onBackKeyClicked();
                // 有弹窗,吃掉物理返回键消息(不是很严谨,你懂的)
                return true;
            }
            // 无弹窗,不吃
            return false;
        },

        /**
         * 递增_touchPriorityIndex
         * @private
         */
        _incTouchPriorityIndex: function() {
            _touchPriorityIndex -= 10;
        }
    };
})(common || (common = {}));

