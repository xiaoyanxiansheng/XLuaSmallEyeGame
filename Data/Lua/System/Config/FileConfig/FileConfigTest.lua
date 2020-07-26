
local LuaConfigTest = LuaConfigTest2
-- 存在
print(LuaConfigTest[5].ID)
print(LuaConfigTest[5].line1)
print(LuaConfigTest[5].line2)

-- 不存在
print(LuaConfigTest[5].line22)
print(LuaConfigTest[6])

print("===============================")
for k,vs in pairs(LuaConfigTest) do
	for i,v in ipairs(vs) do
		print(i,type(v))
	end
end
print("===============================")
--[[for k,v in pairs({[1]=1,[4]=2,[2]="aaaa"}) do
	print(k,v)
end
--]]
for k,vs in ipairs(LuaConfigTest) do
	for i,v in ipairs(vs) do
		print(i,type(v))
	end
end
--[[for k,v in ipairs({1,2,3,4,5}) do
	print(k,v)
end
--]]