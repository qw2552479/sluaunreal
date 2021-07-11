--------------------------------------------------------------------
--- Copyright (C) 2021 
---
--- ModuleName: MessageBox
--- Date: 2021/7/4
--- Author: tom admin
--- ChangeList:
--- Desc: 消息弹框
--------------------------------------------------------------------

---@class MessageBox 消息弹框
local MessageBox = Class('MessageBox')


---@class MessageBoxButtonOptions 弹框按钮参数
---@field text string 按钮显示的文本
---@field onClick fun(msgBox:MessageBox, s:string):MessageBox 消息弹窗按钮点击回调. msgBox: 消息框实例. 返回true才会关闭弹窗
---


---弹出一个MessageBox
---@param text string 显示文本
---@param buttons MessageBoxButtonOptions[] 显示的操作按钮（最多两个）
---@param title string 标题
---@param textAlign number 文本的水平布局 0-left 1-center 2-right
---@param textVAlign number 文本的垂直布局 0-top 1-center 2-bottom
---@param allowClose boolean  是否显示关闭按钮
---@param textColor FColor | string  文本的颜色
---@param onClose fun(): void 关闭前的回调
---@example
--- MessageBox.show(
---  '这是一个Example',
---  [{
---    text: '确定',
---    callback: function() {
---      // do something
---        return true; // return false 不会关闭弹窗
---    }}],
---  '温馨提示',
---  TEXT_ALIGNMENT_CENTER,
---  VERTICAL_TEXT_ALIGNMENT_CENTER,
---  true,
---  '#ff00ff',
---  function () {
---      // do something
---      return true; // return false 不会关闭弹窗
---  });
---
--- @example
--- --只有一个按钮时，可以简写如下
--- MessageBox.show(
---  '这是一个Example',
---  [{}],
---  '温馨提示',
---  TEXT_ALIGNMENT_CENTER,
---  VERTICAL_TEXT_ALIGNMENT_CENTER);
---
function MessageBox.show(text, buttons, title, textAlign, textVAlign, allowClose, textColor, onClose)

end

return MessageBox