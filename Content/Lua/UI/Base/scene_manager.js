/**
 * @namespace
 */
var common;
(function(common) {
    /**
     * 场景管理器
     * @class
     * @static
     * @DDGroup UI管理器,1
     */
    common.SceneManager = {
        _TAG: 'common.SceneManager',

        /**
         * 场景根视图控制器
         * 在切换场景时,在调用切换场景前,
         * 必须将新场景的主controller设置为当前根controller
         * @type {common.ViewController}
         * @private
         */
        _rootController: null,

        /**
         * 获取当前controller
         * @returns {common.SceneController}
         */
        getCurrentController: function() {
            return common.SceneManager._rootController;
        },

        /**
         * 获取当前场景主controller
         * @param {common.SceneController} controller
         */
        setCurrentController: function(controller) {
            common.TodoTaskManager.clearAllTasks();
            common.WindowManager.clearWindowStack();
            common.SceneManager._rootController = controller;
        },

        /**
         * 将新的场景压入当前场景栈中
         * @param {common.SceneControllerConfig} params
         * @param {boolean} dontHide
         */
        pushAScene: function(params, dontHide) {
            // 判断有效性
            var currentController = common.SceneManager.getCurrentController();
            if (!currentController) {
                dd.LOGE(this._TAG, '没有找到当前 controller, 取消弹场景增操作!!!');
                return;
            }

            var newSceneController = common.SceneController.create(params, true);
            if (!newSceneController) {
                dd.LOGE(this._TAG, '创建弹出层失败, 取消弹场景增操作!!!');
                return;
            }

            common.WindowManager.clearWindowStack();
            currentController.pushSceneController(newSceneController, dontHide);
        },

        /**
         * 弹出一个场景
         */
        popAScene: function() {
            var currentController = common.SceneManager.getCurrentController();

            if (!currentController) {
                dd.LOGE(this._TAG, '没有找到当前 controller, 取消弹场景POP操作!!!');
                return;
            }

            currentController.popSceneController();
            common.WindowManager.clearWindowStack();
        },

        /**
         * 场景替换
         * @param {common.SceneControllerConfig} [sceneControllerConfig] 传给controller构造函数的参数
         * @param {string} [transType] 切换特效类型
         * @param {number} [transTime=0.15] 场景过渡动画持续时间
         */
        replaceAScene: function(sceneControllerConfig, transType, transTime) {
            if (__DUDU_DEBUG__) {
                var oldSceneType = common.SceneManager._rootController ? common.SceneManager._rootController.getSceneType() : 'none';
                cc.log(cc.formatStr('场景切换: from %s to %s', oldSceneType, sceneControllerConfig.sceneType));
            }

            transType = transType || common.TransitionType.TRANSITION_NONE;

            switch (transType) {
                case common.TransitionType.TRANSITION_NONE:// 没有切换特效
                    common.SceneManager.replaceASceneWithoutTrans(sceneControllerConfig);
                    break;
                case common.TransitionType.TRANSITION_FADE: // 淡入淡出
                    common.SceneManager.replaceATransitionFadeScene(sceneControllerConfig, transTime);
                    break;
                default: // 默认没有过场动画
                    common.SceneManager.replaceASceneWithoutTrans(sceneControllerConfig);
                    break;
            }
        },

        /**
         * 淡入淡出的切换特效
         * @param {common.SceneControllerConfig} sceneControllerConfig 传给controller构造函数的参数
         * @param {number} transTime 场景过渡动画持续时间
         */
        replaceATransitionFadeScene: function(sceneControllerConfig, transTime) {
            // TODO: 需要确认，渐变过渡场景是不是立即释放此场景。如果不立即释放此场景，destroy延后调用，但是移除所有事件监听
            common.SceneManager.destroyCurrentScene();

            var scene = new cc.Scene();
            var controller = common.SceneController.create(sceneControllerConfig);

            common.SceneManager.setCurrentController(controller);

            scene.addChild(controller.getRootNode());

            var time = transTime || 0;
            var transScene = new cc.TransitionFade(time, scene);
            cc.director.runScene(transScene);
        },

        /**
         * 淡入淡出的切换特效
         * @param {common.SceneControllerConfig} sceneControllerConfig 场景过渡动画持续时间
         */
        replaceASceneWithoutTrans: function(sceneControllerConfig) {
            common.SceneManager.destroyCurrentScene();

            var scene = new cc.Scene();
            var controller = common.SceneController.create(sceneControllerConfig);

            common.SceneManager.setCurrentController(controller);

            scene.addChild(controller.getRootNode());

            cc.director.runScene(scene);
        },

        destroyCurrentScene: function() {
            if (common.SceneManager._rootController) {
                common.SceneManager._rootController.destroy(false);
                common.SceneManager._rootController = null;
            }

            if (__DUDU_DEBUG__) {
                common.ViewController._DEBUG_CHECK_CONTROLLER_LEAK();
            }
        }
    };
})(common || (common = {}));

