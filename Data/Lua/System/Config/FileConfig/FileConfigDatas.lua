--[[
	所有配置表格存储容器

	存储格式：
		文件名
			标题
			行数据
			...
		...
--]]
local FileConfigChunks = FileConfigChunks

-- 所有配置的数据容器
FileConfigDatas = {}

-- 辅助元表
local fileConfigMt = {}		-- 获取配置文件数据
local lineConfigMt = {}		-- 获取配置文件行数据
local cellConfigMt = {}		-- 获取配置文件行列数据

cellConfigMt.__index = function(lineData,name)
	local config = getmetatable(lineData)._super
	-- 查询title中的索引，title和数据的索引是一样的
	local index = config[CONFIG_TITLE_INDEX][name]
	return rawget(lineData,index)
end
cellConfigMt.__newindex = function(lineData,name,value)
	error(string.format("<读取配置错误> 字段和值不允许改变：%s.%s", name, value))
end

-- 解析配置行数据
function ParseConfigLine(configName,configData,lineId)
	-- 1. 获取seek offset
	local offset = FileConfigChunks[configName].map[lineId]
	local path = configName
	local file = io.open(path)
	if file == nil then 
		error(string.format("<读取配置错误> 文件不存在 %s" , path))
	end
	file:seek("set",offset)
	local lineStr = file:read()
	local lineData = string.split(lineStr,"\t")

	local mt = {}
	mt._super = configData
	mt.__index = {}
	if lineId == CONFIG_TITLE_INDEX then 
		for k,v in pairs(lineData) do
			mt.__index[v] = k 		-- 值对应索引: 在获取行列数据时查询索引
		end
	elseif lineId == CONFIG_TYPE_INDEX then
	else
		table.Clone(mt,cellConfigMt)
		-- 类型对应
		local lineTypeData = rawget(configData,CONFIG_TYPE_INDEX)
		for i,v in ipairs(lineData) do
			local ty = lineTypeData[i]
			if ty == "int" then 
				lineData[i] = tonumber(lineData[i])
			end
		end
	end
	setmetatable(lineData,mt)
	
	rawset(configData,lineId,lineData)
	
	file:close()
end

function ParseLineData(configName,configData,lineId)
	-- 是否已经拥有表头数据
	if configData[CONFIG_TITLE_INDEX] == nil then
		-- 解析表头
		ParseConfigLine(configName,configData,CONFIG_TITLE_INDEX)
		-- 解析类型
		ParseConfigLine(configName,configData,CONFIG_TYPE_INDEX)
	end
	-- 解析数据
	if configData[lineId] == nil then 
		ParseConfigLine(configName,configData,lineId)
	end
end

lineConfigMt.__index = function(config,lineId)
	local name = rawget(config,"_name")
	if FileConfigChunks[name] == nil or 
		FileConfigChunks[name].map[lineId] == nil then 
		return nil
	end

	local configData = rawget(config,"configData")
	if configData[lineId] == nil then 
		ParseLineData(name,configData,lineId)
	end
	return configData[lineId]
end
lineConfigMt.__newindex = function(t,lineId,value)
	error(string.format("<读取配置错误> 字段和值不允许改变：%s.%s", lineId, value))
end

fileConfigMt.__index = function(t,name)
	local path = string.format("%s%s.txt",ConfigPath,name)

	if rawget(t,path) == nil then
		-- TODO 只有开发版本才自动解析方便开发 发布版本需要提前解析好
		FileConfigChunks.ReadFileConfigChunks(path)

		local config = {_name=path,_isConfig = true,configData={}} -- _isConfig 是否是配置文件 为了支持顺序遍历
		setmetatable(config,lineConfigMt)
		rawset(t,path,config) 
	end

	return rawget(t,path)
end
fileConfigMt.__newindex = function(t,name,value)
	error(string.format("<读取配置错误> 字段和值不允许改变：%s.%s", name, value))
end

setmetatable(FileConfigDatas,fileConfigMt)