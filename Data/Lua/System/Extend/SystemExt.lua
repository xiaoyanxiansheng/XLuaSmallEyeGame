--[[
	扩展原有系统功能	
--]]

--------------------------------  extend: table ------------------------------
-- 克隆
function table.Clone(tt,tf,isNotCover)
    if nil == tt or nil == tf then return end
    for k, v in pairs(tf) do
        if not isNotCover or nil == tt[k] then 
            tt[k] = v
        end
    end
end

-- table中是否存在某个值
function table.ContainValue(t,value,param1,param2)
    local containIndex = 0;
    if t then
        for i, v in pairs(t) do
            if not param1 then
                if v == value then
                    containIndex = i;
                    break;
                end
            elseif not param2 then
                if v[param1] == value then
                    containIndex = i;
                    break;
                end
            else
                if v[param1][param2] == value then
                    containIndex = i;
                    break;
                end
            end
        end
    end
    return containIndex;
end

--------------------------------  extend: string ------------------------------
-- 分割字符串
function string.split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
      	return {s}
    end

    local t = {}
    local start = 1
    while true do
        local tempStart , tempEnd = string.find (s, delim, start)
        if not tempStart then
          break
        end
        table.insert (t, string.sub (s, start, tempStart - 1))
        start = tempEnd + 1
    end
    local endStr = string.sub (s, start)
    if endStr ~= nil and endStr ~= "" then
        table.insert (t, endStr)
    end

    return t
end

--------------------------------  extend: 迭代器 ------------------------------
-- 扩展迭代器的目的 1：遍历配置数据方式统一 2：配置数据能顺序遍历
function ipairs(a) 
    local func = nil
    local _isConfig = rawget(a,"_isConfig")
    if _isConfig then
        -- 配置表迭代方式 前2行是title和类型定义所以排除掉
        local i = 2
        local configName = rawget(a,"_name")
        local list = FileConfigChunks[configName].list
        local config = FileConfigDatas[configName]
        func = function()
            i = i + 1
            local id = list[i]
            if id == nil then return nil end
            local v = config[id]
            return i, v , id
        end
    else
        -- 原始迭代方式
        func = function(a,i)
            local i = i + 1
            local v =  a[i]
            if v ~= nil then 
                return i ,v
            end
        end
    end
    return func,a,0
end
function pairs(a)
    local func = nil

    local _isConfig = rawget(a,"_isConfig")
    if _isConfig then
        -- 配置表迭代方式 前2行是title和类型定义所以排除掉
        local i = 2
        local configName = rawget(a,"_name")
        local list = FileConfigChunks[configName].list
        local config = FileConfigDatas[configName]
        func = function()
            i = i + 1
            local id = list[i]
            if id == nil then return nil end
            local v = config[id]
            return id, v
        end
    else
        -- 原始迭代方式
        local k = nil
        local v
        func = function()
            k , v = next(a,k)
            if k ~= nil then 
                return k , v
            end
        end
    end

    return func
end