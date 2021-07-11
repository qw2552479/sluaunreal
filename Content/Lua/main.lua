--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: main
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc: 
--------------------------------------------------------------------

Class = require('Core.Class')

--- Const Begin
Enums = require('Types.Enums')
--- Const End

--- UI Begin
ViewController = require('UI.Base.ViewController')
AdaptationController = require('UI.Base.AdaptationController')
require('UI.Base.WindowController')
require('UI.Base.LayoutController')
require('UI.Base.SceneController')
require('UI.Widgets.ActivityIndicator')
require('UI.Widgets.MessageBox')
require('UI.Widgets.Toast')
--- UI End

__DUDU_DEBUG__ = false