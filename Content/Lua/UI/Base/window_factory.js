/**
 * @namespace
 */
var common;
(function(common) {
    /**
     * @typedef {object} common.WindowControllerConfig
     * @property {string} event 弹窗命令事件
     * @property {Class<common.WindowController>} class 弹窗类名
     * @property {dd.CsdFileBinder} csd csd路径
     * @property {string} [configKey] 弹窗配置键
     */

    var _windowKeyMap = []; // 注册弹窗配置
    var _replaceKeyMap = {}; // 自定义皮肤信息
    var _listenerCustomMap = {}; // 自定义监听列表

    /**
     * 窗口工厂类,负责创建弹窗实例,监听创建弹窗命令事件
     * 初始化时监听事件,解析弹窗配置信息并缓存
     * windowKeyCmd:即是窗口唯一键,又是全局事件键
     * 单例
     * @class
     * @static
     * @DDGroup UI管理器,1
     */
    common.WindowFactory = {
        _TAG: 'common.WindowFactory',

        /**
         * 初始化
         */
        init: function() {
            common.WindowFactory.initWindowKeyMap();
        },

        /**
         * 注册弹窗配置,格式: ,{event:弹窗命令事件, class:弹窗类名,configKey:弹窗配置键}
         * 在这里配置上,将弹窗事件,弹窗,弹窗配置关联起来,其他的就不用管了
         */
        initWindowKeyMap: function() {
        },

        /**
         * 其他模块通过该接口注册窗口，注册后，可以通过事件触发弹窗
         * @param {common.WindowControllerConfig} windowInfo
         * @param {boolean} [isOneTimeRegister=true]
         */
        registerWindow: function(windowInfo, isOneTimeRegister) {
            // 默认都是单次注册，第二次注册时会将上次注册的事件销毁
            isOneTimeRegister = isOneTimeRegister === undefined ? true : isOneTimeRegister;
            if (isOneTimeRegister) {
                common.WindowFactory._removeBindItemByEvent(windowInfo.event);
            }
            _windowKeyMap.push(windowInfo);
            common.WindowFactory._registerOneListener(windowInfo, isOneTimeRegister);
        },

        /**
         * 注销窗口
         * @param {string} event 窗口事件名
         */
        unRegisterWindow: function(event) {
            if (!event) {
                return;
            }
            common.WindowFactory._removeBindItemByEvent(event);
            var listenerFunc = _listenerCustomMap[event];
            if (listenerFunc) {
                dd.NotificationCenter.ignore(event, listenerFunc, common.WindowFactory);
                _listenerCustomMap[event] = null;
            }
        },

        setReplaceSkinKeyMap: function(replaceKeyMap) {
            _replaceKeyMap = replaceKeyMap;
        },

        /**
         * 清除替换皮肤
         */
        cleanReplaceSkinKeyMap: function() {
            _replaceKeyMap = null;
        },

        /**
         * 根据配置注册一个单独的监听
         * isOneTimeRegister是否是一次性注册的,common和大厅注册是一次性的,不会变更.其他的需要支持覆盖和注销
         * @param item
         * @param isOneTimeRegister
         * @private
         */
        _registerOneListener: function(item, isOneTimeRegister) {
            var itemEvent = item.event;
            if (itemEvent) {
                /**
                 * 动态创建监听回调方法
                 * @param param 传递给弹窗的数据
                 * @ignore
                 */
                var listenerFunc = function(param) {
                    common.WindowFactory._onPopWindowEvent(itemEvent, param);
                };

                if (isOneTimeRegister) {
                    // 如果是一次注册的事件，需要先销毁已经注册的事件
                    if (_listenerCustomMap[itemEvent]) {
                        // 已经注册了,要注销掉原来的监听
                        dd.NotificationCenter.ignore(itemEvent, _listenerCustomMap[itemEvent], common.WindowFactory);
                        _listenerCustomMap[itemEvent] = null;
                    }
                    // 将新创建的监听保存到数组中
                    _listenerCustomMap[itemEvent] = listenerFunc;
                }

                dd.NotificationCenter.listen(itemEvent, listenerFunc, common.WindowFactory);
            } else {
                dd.LOGW(common.WindowFactory._TAG, '注册了无效的数据:' + JSON.stringify(item));
            }
        },

        /**
         * 弹窗事件处理
         * @param itemEvent
         * @param param 传递给弹窗的数据
         * @private
         */
        _onPopWindowEvent: function(itemEvent, param) {
            var curController = common.SceneManager.getCurrentController();
            if (!curController) {
                // 如果此时没有场景层，直接退出，没必要再创建新的窗口了。
                dd.LOGE(this._TAG, '未找到场景层，itemEvent: ' + itemEvent);
                return;
            }
            var item = common.WindowFactory._findBindItemByEvent(itemEvent);

            var itemCsd = item.csd;
            var itemClass = item.class;
            var itemConfigInfo = item.configInfo;

            param = param || {};
            // 创建弹窗实例
            var newWindow = new itemClass();
            // 不再从本地加载窗口配置
            if (itemConfigInfo) {
                param.windowConfig = itemConfigInfo;
            }
            // 初始化
            if (newWindow && newWindow._setWindowParam(param)) {
                // 如果初始化成功,则将弹窗显示在当前场景中
                newWindow.init(itemCsd);
                common.WindowFactory._popWindow(newWindow);
            }
        },

        /**
         * 从_windowKeyMap中移除指定事件，防止多次进入子游戏，_windowKeyMap重复添加
         * @param {string} event
         * @private
         */
        _removeBindItemByEvent: function(event) {
            for (var i = 0; i < _windowKeyMap.length; i++) {
                if (_windowKeyMap[i].event === event) {
                    _windowKeyMap.splice(i, 1);
                    return;
                }
            }
        },
        /**
         * 在_replaceKeyMap和_windowKeyMap找到配置绑定信息
         * @param event
         * @returns {common.WindowControllerConfig}
         * @private
         */
        _findBindItemByEvent: function(event) {
            var ret = {};
            var item = null;
            var replaceItem = null;
            // 找大厅配置
            for (var i = 0; i < _windowKeyMap.length; i++) {
                if (_windowKeyMap[i].event === event) {
                    item = _windowKeyMap[i];
                    break;
                }
            }

            if (!item) {
                dd.LOGW(common.WindowFactory._TAG, '发现错误的事件监听:' + event);
            } else {
                // 复制
                dd.deepCopy(item, ret);
                if (replaceItem) {
                    dd.deepCopy(replaceItem, ret);
                }
            }
            return ret;
        },

        /**
         * 将弹窗弹出来
         * @param {common.WindowController} window
         * @private
         */
        _popWindow: function(window) {
            if (window) {
                if (common.WindowManager.addWindow(window)) {
                    window.showWindow();
                }
            } else {
                dd.LOGE(common.WindowFactory._TAG, '_popWindow 参数错误: window is undefined');
            }
        }
    };
})(common || (common = {}));


