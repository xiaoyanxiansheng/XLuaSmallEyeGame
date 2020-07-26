-- TODO 使用描述

local _CHECK_MODE = true -- 运行时类型检测 发布时可以选择关闭 这样会提升性能

local error = error
local print = function(...) 
		if _CHECK_MODE then 
			print(...) 
		end 
	end

-- 类型系统根节点
typesys = {}
-- 类型映射表类型存储在typesys中
local _type_info_map = {}
-- 实例自增ID
local _obj_last_id = 0;

-------- 辅助函数 ---------
-- 类型是否相同
local function _type_isType(t1,t2)
	local info = _type_info_map[t1]
	local t = t1
	while nil ~= t do 
		if t == t2 then 
			return true
		end
		t = t.__super
	end
	return false
end
-- 值类型
local function _v_getType(v)
	if "table" == type(v) then 
		if nil ~= v.__type then 
			return v.__type
		end
	end
	return type(v)
end
-- 对象(或类型)名称
local function _v_getTypeName(v)
	local typeName = type(v)
	if "table" == typeName then
		local t = v.__type
		if nil ~= t then 
			return t.__type_name
		end
	end
	return typeName
end

-------- 实例相关 ---------
local _obj_mt = {}
_obj_mt.__index = function(obj,k)
	-- 实例中查找 or 类型中查找(函数或者静态变量)
	local value = obj._fields[k] 
	if nil == value then 
		value = obj.__type[k]
	end
	if nil == value then 
		error(string.format("<字段获取错误> 字段不存在：%s.%s", obj.__type.__type_name, fieldName))
	end
	return value
end
_obj_mt.__newindex = function(obj,k,v)
	local value = obj._fields[k]
	if nil ~= value then
		if not _type_isType(_v_getType(value),_v_getType(v)) then 
			error(string.format("<字段赋值错误> 类型不匹配：%s 无法赋值给 %s", _v_getTypeName(v) , _v_getTypeName(value)))			
		end
		obj._fields[k] = v
		return
	end

	local t = obj.__type
	if nil ~= t[k] then
		error(string.format("<字段赋值错误> 不允许用对象为类字段赋值：%s.%s", t.__type_name, k))
	end

	error(string.format("<字段赋值错误> 字段不存在：%s.%s", t.__type_name, k))
end

if _CHECK_MODE then

local function _checkField(obj, field_name)
	if "_" == string.sub(field_name, 1, 1) then
		-- 私有，只允许对象自身访问（子类能够访问父类）
		-- getlocal第一个参数：
		-- 1：_checkField
		-- 2：__index or __newindex
		-- 3：调用函数
		local name, value = debug.getlocal(3, 1) 
		if "self" == name and _type_isType(value.__type,obj.__type) then
			return true
		end
		error(string.format("<字段访问错误> 无权限访问：%s.%s", obj.__type.__type_name, field_name))
	end
	return true
end

local obj_index = _obj_mt.__index
_obj_mt.__index = function(t,k)
	-- 访问权限检测
	if not _checkField(t, k) then 
		return nil
	end
	return obj_index(t, k)
end
local obj__newindex = _obj_mt.obj__newindex
_obj_mt.obj__newindex = function(t,k,v)
	-- 访问权限检测
	if not _checkField(t, k) then 
		return nil
	end
	obj__newindex(t,k,v)
end

end

local function _newData(t,...)
	local info = _type_info_map[t]
	if nil == info then 
		error("<new错误> 类型不存在")
	end

	-- 创建对象
	_obj_last_id = _obj_last_id + 1
	local obj = {__type = t , __id = _obj_last_id , _fields = {}}
	-- 拷贝原始数据
	table.CloneTo(obj._fields,info.fields)
	-- 父类构造
	local super = t.__super
	while super do
		local super_obj = _newData(super)
		local raw_super_fields = super_obj._fields
		setmetatable(obj._fields,{__index = raw_super_fields,__newindex = raw_super_fields})
		obj.__super = super_obj

		super = super.__super
	end

	-- 设置对象操作
	setmetatable(obj,_obj_mt)

	return obj
end

local function _new(t, ...)
	local obj = _newData(t, ...)
	if nil ~= t.__ctor then
		t.__ctor(obj,...)
	end
	return obj
end
-------- 类型相关 ---------
typesys.new = _new

local _type_def_mt = {}
local _type_mt = {
	__index = rawget,
	__newindex = rawset
}
_type_def_mt.__call = function(t,proto)
	-- print("------类型定义开始：", t.__type_name,"---------")

	local info = {
	    -- 父类
		super = nil,	
		fields = {},
	}

	local super = proto.__super
	if nil ~= super then 
		local super_info = _type_info_map[super]
		if nil == super_info then 
			error("<类型定义错误> 父类未定义")
		end

		t.__super = super
		local mt = {}
		table.CloneTo(mt,_type_mt,true)
		mt.__index = super
		setmetatable(t,mt)			-- 设置的目的：能向父类访问
	else
		setmetatable(t,_type_mt)	-- 设置的目的：只能访问类型本身
	end

	-- 解析协议
	for fieldName,v in pairs(proto) do
		if "string" ~= type(fieldName) then 
			error("<类型定义错误> 字段名不是字符串类型")
		end

		if "__super" ~= fieldName then 
			info.fields[fieldName] = v
		end
	end

	-- 将类型信息放入到映射表中
	_type_info_map[t] = info

	-- print("------类型定义结束：", t.__type_name,"---------")

	return t
end

-- 类型定义语法糖 
-- 例如：typesys.def.Object{} 定义一个类型Object
typesys.def = setmetatable({},{__index = function(t,name)
		if nil ~= rawget(typesys,name) then 
			error("<类型定义错误> 类型名已存在：" , name)
		end
		-- 绑定类型的操作
		local new_t = setmetatable({__type_name = name},_type_def_mt)
		new_t.__type = new_t -- 自己可以反问自己的类型
		rawset(typesys,name,new_t)
		return new_t
	end})

-- 统一扩展工具的函数放置位置
typesys.tools = {}

-- 禁止typesys添加或访问不存在的字段
setmetatable(typesys, {
	__index = function(t, k)
		error("<typesys访问错误> 不存在："..k)
	end,
	__newindex = function(t, k, v)
		error("<typesys访问错误> 不存在："..k)
	end
})

-- 测试
require "Lua/System/TypeSystem/TypeSystemTest";