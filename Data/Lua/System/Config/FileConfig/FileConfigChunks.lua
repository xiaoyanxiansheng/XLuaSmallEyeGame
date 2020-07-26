--[[
	文件的chunck信息
	存储每个文件每行对应的字节长度，其目的是为了读取文件时不加载整个配置
	存储格式:
		文件名
			行号 offset
			...
		...
--]]

FileConfigChunks = {}

CONFIG_TITLE_INDEX = -2	-- 代表配置表title的索引
CONFIG_TYPE_INDEX = -1	-- 代表配置表中类型的索引

local FileConfigChunksMt = {}

function FileConfigChunksMt.ReadFileConfigChunks(filePath)
	assert(filePath ~= nil,"<文件读取错误> 路径为nil")
	if FileConfigChunks[filePath] ~= nil then 
		-- 已经存在
		return;
	end
	local file = io.open(filePath)
	if file == nil then 
		error(string.format("<文件读取错误> 不存在路径 ：%s",filePath))
	end

	local map = {}
	local list = {}

	FileConfigChunks[filePath] = {}
	FileConfigChunks[filePath].map = map
	FileConfigChunks[filePath].list = list

	local lineIndex = 0
	local preLineLen = 0
	while(true) do
		local line = file:read()
		if line == nil then 
			break
		end
		lineIndex = lineIndex + 1;
		local tempStart , tempEnd = string.find (line, "\t")
        local idStr = string.sub (line, 0, tempStart - 1)
        local id = tonumber(idStr)
        if lineIndex == 2 then 
        	-- title
        	id = CONFIG_TITLE_INDEX
        elseif lineIndex == 3 then
        	-- valueType
			id = CONFIG_TYPE_INDEX
        end
        if id ~= nil then 
        	map[id] = preLineLen
        	table.insert(list,id)
        end

        preLineLen = preLineLen + #line + 2
	end

	file:close()
end

setmetatable(FileConfigChunks,{__index=FileConfigChunksMt})

return FileConfigChunks