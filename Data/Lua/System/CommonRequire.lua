-- 全局变量
require "Lua/System/GlobalDefine";
-- 全局定义
require "Lua/System/Extend/SystemExt";
-- 配置文件相关
require "Lua/System/Config/FileConfig/ReadConfigDefine";
-- TODO 待删除 table的扩展功能
-- require "Lua/System/tableExt";
-- 类型系统
-- require "Lua/System/TypeSystem/TypeSystem";

--[[
-- 工具
require "Data/Script/Common/UtilFunc";
-- 加载模块
require "Data/Script/Util/ResourceLoad";
-- 类模块
require "Data/ULua/System/Class";
-- 消息模块
require "Data/ULua/System/Message";
-- 状态机模块
require "Data/Script/Common/StateMachine/StateManager"
----------------------- 数据模块 ------------------------
require "Data/Script/Data/TutData";
--]]